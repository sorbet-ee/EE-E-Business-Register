# frozen_string_literal: true

require 'savon'
require 'logger'

module EeEBusinessRegister
  # SOAP client for the Estonian e-Business Register API
  #
  # This class handles all low-level communication with the Estonian e-Business Register
  # SOAP API service. It manages authentication, request/response handling, error handling,
  # and provides automatic retry logic for transient failures.
  #
  # The client is built on top of the Savon SOAP library and includes:
  # - Automatic authentication using WSSE (Web Service Security Extensions)
  # - Intelligent retry logic for rate limiting and timeouts
  # - Comprehensive error handling with specific exception types
  # - Optional logging for debugging and monitoring
  #
  # @example Basic usage
  #   client = Client.new(configuration)
  #   response = client.call(:lihtandmed_v2, ariregistri_kood: '16863232')
  #
  # @example With custom configuration
  #   config = Configuration.new
  #   config.username = 'api_user'
  #   config.password = 'api_pass' 
  #   client = Client.new(config)
  #
  class Client
    # @return [Configuration] The configuration object used by this client
    attr_reader :config
    
    # @return [Savon::Client] The underlying Savon SOAP client for testing
    attr_reader :savon_client
    
    # Initialize a new SOAP client with the provided configuration
    #
    # Sets up the underlying Savon SOAP client with proper authentication,
    # timeouts, and error handling. The configuration is validated during
    # initialization to ensure all required settings are present.
    #
    # @param config [Configuration] Configuration object with API credentials and settings
    # @raise [ConfigurationError] If required configuration is missing or invalid
    # @example
    #   config = Configuration.new
    #   config.username = 'myuser'
    #   config.password = 'mypass'
    #   client = Client.new(config)
    #
    def initialize(config = EeEBusinessRegister.configuration)
      @config = config
      
      # Validate configuration only if it has credentials
      config.validate! if config.credentials_configured?
      
      # Setup logging - use provided logger or create a null logger
      @logger = config.logger || Logger.new(nil)
      
      # Create and configure the underlying Savon SOAP client
      # with Estonian e-Business Register specific settings
      if config.credentials_configured?
        @savon_client = Savon.client(
          wsdl: config.wsdl_url,                    # WSDL location for service definition
          endpoint: config.endpoint_url,            # Actual service endpoint for requests
          open_timeout: config.timeout,             # Connection timeout
          read_timeout: config.timeout,             # Read timeout for responses
          log: @logger.level == Logger::DEBUG,      # Enable Savon logging only in debug mode
          logger: @logger,                          # Logger for Savon internal logging
          wsse_auth: [config.username, config.password], # WS-Security authentication
          namespace_identifier: :ns1,               # XML namespace prefix for requests
          env_namespace: :soap,                     # SOAP envelope namespace
          soap_version: 1,                          # Use SOAP 1.1 (required by Estonian API)
          encoding: 'UTF-8',                        # Character encoding for XML
          convert_request_keys_to: :none            # Preserve original key names in requests
        )
      else
        @savon_client = nil
      end
    end
    
    # Check if the client is properly configured with valid credentials
    #
    # @return [Boolean] true if credentials are configured, false otherwise
    def configured?
      @config.credentials_configured?
    end
    
    # Get list of available SOAP operations
    #
    # @return [Array<Symbol>] List of available operations from the WSDL
    def operations
      return [] unless @savon_client
      @savon_client.operations
    end
    
    # Execute a SOAP operation with automatic retry logic
    #
    # This method handles the actual SOAP request to the Estonian e-Business Register
    # API. It includes intelligent retry logic for transient failures like rate limiting
    # and timeouts, and converts various exception types into user-friendly APIErrors.
    #
    # The method automatically adds the configured language to all requests and
    # handles the following error scenarios:
    # - SOAP faults from the Estonian service
    # - HTTP errors (401, 403, 429, 500, etc.)
    # - Network timeouts with exponential backoff retry
    # - Unexpected errors with proper logging
    #
    # @param operation [Symbol] The SOAP operation name to call (e.g., :lihtandmed_v2)
    # @param message [Hash] Request parameters to send with the operation
    # @return [Savon::Response] Raw SOAP response object
    # @raise [APIError] For any API-related errors (authentication, service faults, etc.)
    # 
    # @example Find company by registry code
    #   response = client.call(:lihtandmed_v2, ariregistri_kood: '16863232')
    #   
    # @example Search companies by name
    #   response = client.call(:nimeparing_v1, nimi: 'Swedbank', max_arv: 10)
    #
    def call(operation, message = {})
      # Ensure client is properly configured before making requests
      unless configured?
        raise AuthenticationError, 'Client is not properly configured. Please provide username and password.'
      end
      
      retries = 0
      max_retries = 3
      
      begin
        # Log the operation being performed (if logging is enabled)
        @logger.info "Calling #{operation} with params: #{message}" if @logger
        
        # Ensure all requests include the configured language
        # This tells the Estonian API which language to use for responses
        message[:keel] = @config.language unless message.key?(:keel)
        
        # Add authentication credentials to the message body
        # The Estonian API expects credentials in the request body, not just WSSE headers
        message[:ariregister_kasutajanimi] = @config.username
        message[:ariregister_parool] = @config.password
        
        # All operations use the "keha" wrapper for consistency
        # The Estonian API expects all parameters wrapped in "keha"
        wrapped_message = {
          keha: message
        }
        
        # Execute the actual SOAP request via Savon
        response = @savon_client.call(operation, message: wrapped_message)
        
        # Log successful response (debug level to avoid spam)
        @logger.debug "Response received: #{response.body}" if @logger
        
        response
        
      rescue Savon::SOAPFault => e
        # Handle SOAP faults from the Estonian service
        # These usually indicate business logic errors (company not found, etc.)
        @logger.error "SOAP Fault: #{e.message}" if @logger
        raise APIError, "SOAP Fault: #{e.message}"
        
      rescue Savon::HTTPError => e
        # Handle HTTP-level errors with special logic for rate limiting
        if e.http.code == 429 && retries < max_retries
          # Estonian API rate limiting - use exponential backoff
          sleep_time = 2 ** retries
          @logger.warn "Rate limited, retrying in #{sleep_time}s (attempt #{retries + 1}/#{max_retries})" if @logger
          sleep(sleep_time)
          retries += 1
          retry
        end
        
        # Log and re-raise other HTTP errors
        @logger.error "HTTP Error: #{e.http.code} - #{e.message}" if @logger
        raise APIError, "HTTP Error: #{e.http.code} - #{e.message}"
        
      rescue Timeout::Error, Net::ReadTimeout => e
        # Handle network timeouts with retry logic
        if retries < max_retries
          retries += 1
          @logger.warn "Timeout occurred, retrying (attempt #{retries}/#{max_retries})" if @logger
          retry
        end
        
        # Max retries exceeded - give up
        @logger.error "Request timeout after #{max_retries} attempts: #{e.message}" if @logger
        raise APIError, "Request timeout: #{e.message}"
        
      rescue => e
        # Catch-all for unexpected errors - log details and re-raise as APIError
        @logger.error "Unexpected error in SOAP call: #{e.class} - #{e.message}" if @logger
        raise APIError, "Request failed: #{e.message}"
      end
    end
    
    # Check if the Estonian e-Business Register API is accessible and responding
    #
    # Performs a simple API call to verify that the service is available and
    # responding correctly. Uses a well-known Estonian company registry code
    # (Estonian Business Registry itself - 10060701) for the test.
    #
    # This method swallows all exceptions and returns a simple boolean,
    # making it safe to use for health checks and monitoring.
    #
    # @return [Boolean] true if API is accessible and responding, false otherwise
    # @example
    #   if client.healthy?
    #     puts "API is working"
    #   else
    #     puts "API is down or unreachable"
    #   end
    #
    def healthy?
      # Use Estonian Business Registry's own registry code for health check
      # This is a stable, well-known entity that should always exist
      call(:lihtandmed_v2, ariregistri_kood: '10060701')
      true
    rescue
      # Any error means the API is not healthy
      false
    end
  end
  
end