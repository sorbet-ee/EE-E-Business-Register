# frozen_string_literal: true

module EeEBusinessRegister
  # Base exception class for all Estonian e-Business Register gem errors
  #
  # This serves as the parent class for all custom exceptions raised by the gem.
  # Catching this exception will capture any error originating from the gem's
  # internal operations, making it useful for general error handling.
  #
  # @example Catch all gem-related errors
  #   begin
  #     company = EeEBusinessRegister.find_company('16863232')
  #   rescue EeEBusinessRegister::Error => e
  #     puts "Estonian register error: #{e.message}"
  #   end
  #
  class Error < StandardError; end
  
  # Raised when API authentication fails
  #
  # This exception is thrown when the Estonian e-Business Register API
  # rejects the provided username and password credentials. Common causes:
  # - Incorrect username or password
  # - Account suspended or expired  
  # - Network issues preventing proper authentication
  #
  # @example Handle authentication errors
  #   begin
  #     EeEBusinessRegister.find_company('16863232')
  #   rescue EeEBusinessRegister::AuthenticationError
  #     puts "Please check your API credentials"
  #   end
  #
  class AuthenticationError < Error; end
  
  # Raised for all Estonian API communication and service errors
  #
  # This is the most common exception type, covering various API-related failures:
  # - Network connectivity issues
  # - Estonian service downtime or maintenance
  # - Rate limiting (too many requests)
  # - SOAP service faults (data not found, invalid requests)
  # - HTTP errors (500, 503, etc.)
  # - Request timeouts
  #
  # The error message typically includes specific details about what went wrong
  # and suggestions for resolution (retry later, check parameters, etc.).
  #
  # @example Handle API errors gracefully
  #   begin
  #     company = EeEBusinessRegister.find_company('16863232')
  #   rescue EeEBusinessRegister::APIError => e
  #     if e.message.include?("timeout")
  #       puts "Service is slow, please try again"
  #     elsif e.message.include?("not found") 
  #       puts "Company does not exist"
  #     else
  #       puts "API error: #{e.message}"
  #     end
  #   end
  #
  class APIError < Error; end
  
  # Raised when gem configuration is invalid or incomplete
  #
  # This exception occurs when required configuration settings are missing
  # or have invalid values. Most commonly raised during initial setup when
  # username, password, or other required settings are not provided.
  #
  # @example Handle configuration errors
  #   begin
  #     EeEBusinessRegister.configure do |config|
  #       config.username = nil  # This will cause an error
  #     end
  #   rescue EeEBusinessRegister::ConfigurationError => e
  #     puts "Configuration problem: #{e.message}"
  #   end
  #
  class ConfigurationError < Error; end
  
  # Raised when user input fails validation rules
  #
  # This exception is thrown when user-provided data doesn't meet the
  # required format or contains potentially dangerous content. Examples:
  # - Registry codes that aren't exactly 8 digits
  # - Invalid date formats
  # - Empty or malformed search queries
  # - Input that could cause security issues
  #
  # @example Handle validation errors  
  #   begin
  #     company = EeEBusinessRegister.find_company('invalid-code')
  #   rescue EeEBusinessRegister::ValidationError => e
  #     puts "Input error: #{e.message}"
  #   end
  #
  class ValidationError < Error; end
end