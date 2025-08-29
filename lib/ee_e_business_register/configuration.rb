# frozen_string_literal: true

module EeEBusinessRegister
  # Configuration class for the Estonian e-Business Register API client
  #
  # This class handles all configuration options required to connect to and interact
  # with the Estonian e-Business Register SOAP API service. It supports both
  # production and test environments with sensible defaults.
  #
  # @example Basic configuration
  #   config = Configuration.new
  #   config.username = 'your_username'
  #   config.password = 'your_password'
  #   config.validate!
  #
  # @example Test mode configuration
  #   config = Configuration.new
  #   config.username = 'test_user'
  #   config.password = 'test_pass'
  #   config.test_mode!
  #
  class Configuration
    # API authentication credentials - required for all API calls
    # @return [String] API username provided by Estonian Business Registry
    attr_accessor :username
    
    # @return [String] API password provided by Estonian Business Registry  
    attr_accessor :password
    
    # SOAP service endpoints for the Estonian e-Business Register
    # @return [String] WSDL URL for service definition (auto-set based on environment)
    attr_accessor :wsdl_url
    
    # @return [String] Endpoint URL for actual API calls (auto-set based on environment)
    attr_accessor :endpoint_url
    
    # API request configuration options
    # @return [String] Response language: 'eng' for English, 'est' for Estonian (default: 'eng')
    attr_accessor :language
    
    # @return [Integer] HTTP request timeout in seconds (default: 30)
    attr_accessor :timeout
    
    # @return [Boolean] Whether using test environment endpoints (default: false)
    attr_accessor :test_mode
    
    # @return [Logger, nil] Optional logger instance for debugging API calls (default: nil)
    attr_accessor :logger
    
    # Initialize configuration with production defaults
    #
    # Sets up the configuration with sensible defaults for production use.
    # You must set username and password before making API calls.
    #
    def initialize
      # Production API endpoints - official Estonian e-Business Register
      @wsdl_url = 'https://ariregxmlv6.rik.ee/?wsdl'
      @endpoint_url = 'https://ariregxmlv6.rik.ee/'
      
      # Default to English responses and 30-second timeout
      @language = 'eng'
      @timeout = 30
      
      # Start in production mode without logging
      @test_mode = false
      @logger = nil
    end
    
    # Switch to test environment endpoints
    #
    # Changes the WSDL and endpoint URLs to use the Estonian e-Business Register
    # test environment. Useful for development and testing without affecting
    # production data or hitting rate limits.
    #
    # @return [Boolean] Always returns true
    # @example
    #   config = Configuration.new
    #   config.test_mode!
    #   # Now uses test endpoints
    #
    def test_mode!
      @test_mode = true
      @wsdl_url = 'https://demo-ariregxmlv6.rik.ee/?wsdl'
      @endpoint_url = 'https://demo-ariregxmlv6.rik.ee/'
    end
    
    # Validate that all required configuration is present and valid
    #
    # Checks that username and password are provided and that language
    # is one of the supported options. Should be called before making
    # any API requests to ensure proper configuration.
    #
    # @return [Boolean] Returns true if valid
    # @raise [ConfigurationError] If any required setting is missing or invalid
    # @example
    #   config.username = 'myuser'
    #   config.password = 'mypass'
    #   config.validate! # => true
    #
    def validate!
      # Ensure API credentials are provided
      raise ConfigurationError, 'Username is required' if username.nil? || username.empty?
      raise ConfigurationError, 'Password is required' if password.nil? || password.empty?
      
      # Validate language setting
      unless %w[eng est].include?(language)
        raise ConfigurationError, 'Language must be eng (English) or est (Estonian)'
      end
      
      true
    end
    
    # Switch to production environment endpoints
    #
    # Switches back to production URLs after being in test mode
    # @return [Boolean] Always returns true
    def production_mode!
      @test_mode = false
      @wsdl_url = 'https://ariregxmlv6.rik.ee/?wsdl'
      @endpoint_url = 'https://ariregxmlv6.rik.ee/'
    end
    
    # Check if we're in test mode
    #
    # @return [Boolean] true if in test mode, false otherwise
    def test_mode?
      @test_mode == true
    end
    
    # Check if we're in production mode
    #
    # @return [Boolean] true if in production mode, false otherwise  
    def production_mode?
      @test_mode != true
    end
    
    # Check if credentials are properly configured
    #
    # @return [Boolean] true if both username and password are present
    def credentials_configured?
      !username.nil? && !username.empty? && !password.nil? && !password.empty?
    end
    
    # Export configuration as hash
    #
    # @return [Hash] Configuration values with password masked for security
    def to_h
      {
        wsdl_url: @wsdl_url,
        endpoint_url: @endpoint_url,
        language: @language,
        timeout: @timeout,
        username: @username,
        password: @password.nil? ? nil : "[MASKED]",
        environment: test_mode? ? "test" : "production"
      }
    end
  end
  
end