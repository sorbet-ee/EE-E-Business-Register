# frozen_string_literal: true

require_relative 'test_helper'

class TestErrors < Minitest::Test
  # ========================================
  # BASE ERROR CLASS TESTS
  # ========================================

  def test_error_inheritance
    assert EeEBusinessRegister::Error < StandardError
    assert EeEBusinessRegister::AuthenticationError < EeEBusinessRegister::Error
    assert EeEBusinessRegister::APIError < EeEBusinessRegister::Error
    assert EeEBusinessRegister::ConfigurationError < EeEBusinessRegister::Error
    assert EeEBusinessRegister::ValidationError < EeEBusinessRegister::Error
  end

  def test_error_basic_functionality
    error = EeEBusinessRegister::Error.new("Test error message")
    assert_equal "Test error message", error.message
    assert_kind_of EeEBusinessRegister::Error, error
  end

  def test_error_without_message
    error = EeEBusinessRegister::Error.new
    assert_kind_of EeEBusinessRegister::Error, error
  end

  # ========================================
  # AUTHENTICATION ERROR TESTS
  # ========================================

  def test_authentication_error_basic
    error = EeEBusinessRegister::AuthenticationError.new("Invalid credentials")
    assert_equal "Invalid credentials", error.message
    assert_instance_of EeEBusinessRegister::AuthenticationError, error
    assert_kind_of EeEBusinessRegister::Error, error
  end

  def test_authentication_error_rescue_as_base_error
    begin
      raise EeEBusinessRegister::AuthenticationError.new("Auth failed")
    rescue EeEBusinessRegister::Error => e
      assert_instance_of EeEBusinessRegister::AuthenticationError, e
      assert_equal "Auth failed", e.message
    end
  end

  # ========================================
  # API ERROR TESTS
  # ========================================

  def test_api_error_basic
    error = EeEBusinessRegister::APIError.new("API request failed")
    assert_equal "API request failed", error.message
    assert_instance_of EeEBusinessRegister::APIError, error
    assert_kind_of EeEBusinessRegister::Error, error
  end

  def test_api_error_with_soap_fault_message
    message = "SOAP Fault: Company not found"
    error = EeEBusinessRegister::APIError.new(message)
    assert_equal message, error.message
    assert_includes error.message, "SOAP Fault"
  end

  def test_api_error_with_http_error_message
    message = "HTTP Error: 500 - Internal Server Error"
    error = EeEBusinessRegister::APIError.new(message)
    assert_equal message, error.message
    assert_includes error.message, "HTTP Error"
  end

  def test_api_error_with_timeout_message
    message = "Request timeout: Connection timed out"
    error = EeEBusinessRegister::APIError.new(message)
    assert_equal message, error.message
    assert_includes error.message, "timeout"
  end

  def test_api_error_rescue_as_base_error
    begin
      raise EeEBusinessRegister::APIError.new("API failed")
    rescue EeEBusinessRegister::Error => e
      assert_instance_of EeEBusinessRegister::APIError, e
      assert_equal "API failed", e.message
    end
  end

  # ========================================
  # CONFIGURATION ERROR TESTS
  # ========================================

  def test_configuration_error_basic
    error = EeEBusinessRegister::ConfigurationError.new("Username is required")
    assert_equal "Username is required", error.message
    assert_instance_of EeEBusinessRegister::ConfigurationError, error
    assert_kind_of EeEBusinessRegister::Error, error
  end

  def test_configuration_error_typical_messages
    typical_messages = [
      "Username is required",
      "Password is required",
      "Language must be eng (English) or est (Estonian)",
      "Invalid configuration parameter"
    ]

    typical_messages.each do |message|
      error = EeEBusinessRegister::ConfigurationError.new(message)
      assert_equal message, error.message
    end
  end

  def test_configuration_error_rescue_as_base_error
    begin
      raise EeEBusinessRegister::ConfigurationError.new("Config invalid")
    rescue EeEBusinessRegister::Error => e
      assert_instance_of EeEBusinessRegister::ConfigurationError, e
      assert_equal "Config invalid", e.message
    end
  end

  # ========================================
  # VALIDATION ERROR TESTS
  # ========================================

  def test_validation_error_basic
    error = EeEBusinessRegister::ValidationError.new("Invalid registry code format")
    assert_equal "Invalid registry code format", error.message
    assert_instance_of EeEBusinessRegister::ValidationError, error
    assert_kind_of EeEBusinessRegister::Error, error
  end

  def test_validation_error_typical_messages
    typical_messages = [
      "Invalid registry code format '123'. Must be exactly 8 digits.",
      "Invalid date format 'invalid-date'. Use YYYY-MM-DD format.",
      "Invalid language 'invalid'. Must be one of: eng, est",
      "Page number must be 1 or greater, got 0",
      "Results limit too large (max 100), got 200"
    ]

    typical_messages.each do |message|
      error = EeEBusinessRegister::ValidationError.new(message)
      assert_equal message, error.message
    end
  end

  def test_validation_error_rescue_as_base_error
    begin
      raise EeEBusinessRegister::ValidationError.new("Validation failed")
    rescue EeEBusinessRegister::Error => e
      assert_instance_of EeEBusinessRegister::ValidationError, e
      assert_equal "Validation failed", e.message
    end
  end

  # ========================================
  # ERROR HIERARCHY TESTS
  # ========================================

  def test_catch_all_errors_with_base_class
    errors = [
      EeEBusinessRegister::AuthenticationError.new("Auth error"),
      EeEBusinessRegister::APIError.new("API error"),
      EeEBusinessRegister::ConfigurationError.new("Config error"),
      EeEBusinessRegister::ValidationError.new("Validation error")
    ]

    errors.each do |error|
      begin
        raise error
      rescue EeEBusinessRegister::Error => e
        assert_instance_of error.class, e
        assert_includes e.message, "error"
      end
    end
  end

  def test_specific_error_rescue_priority
    # More specific rescue blocks should catch before general ones
    caught_error = nil

    begin
      raise EeEBusinessRegister::AuthenticationError.new("Auth failed")
    rescue EeEBusinessRegister::AuthenticationError => e
      caught_error = :authentication
    rescue EeEBusinessRegister::Error => e
      caught_error = :generic
    end

    assert_equal :authentication, caught_error
  end

  def test_standard_error_rescue_catches_all
    errors = [
      EeEBusinessRegister::Error.new("Base error"),
      EeEBusinessRegister::AuthenticationError.new("Auth error"),
      EeEBusinessRegister::APIError.new("API error"),
      EeEBusinessRegister::ConfigurationError.new("Config error"),
      EeEBusinessRegister::ValidationError.new("Validation error")
    ]

    errors.each do |error|
      begin
        raise error
      rescue StandardError => e
        assert_instance_of error.class, e
      end
    end
  end

  # ========================================
  # ERROR MESSAGE FORMATTING TESTS
  # ========================================

  def test_error_message_with_nil
    error = EeEBusinessRegister::Error.new(nil)
    assert_kind_of EeEBusinessRegister::Error, error
  end

  def test_error_message_with_empty_string
    error = EeEBusinessRegister::Error.new("")
    assert_equal "", error.message
  end

  def test_error_message_with_special_characters
    message = "Error with special chars: àáâãäåæçèéêë & <>'\" symbols"
    error = EeEBusinessRegister::Error.new(message)
    assert_equal message, error.message
  end

  def test_error_message_with_unicode
    message = "Eesti keel: õäöüš and 中文字符"
    error = EeEBusinessRegister::Error.new(message)
    assert_equal message, error.message
  end

  # ========================================
  # NESTED MODULE STRUCTURE TESTS
  # ========================================

  def test_error_classes_in_correct_module
    assert_equal EeEBusinessRegister::Error, EeEBusinessRegister.const_get(:Error)
    assert_equal EeEBusinessRegister::AuthenticationError, EeEBusinessRegister.const_get(:AuthenticationError)
    assert_equal EeEBusinessRegister::APIError, EeEBusinessRegister.const_get(:APIError)
    assert_equal EeEBusinessRegister::ConfigurationError, EeEBusinessRegister.const_get(:ConfigurationError)
    assert_equal EeEBusinessRegister::ValidationError, EeEBusinessRegister.const_get(:ValidationError)
  end

  def test_validation_module_error_distinct_from_main_validation_error
    # The Validation module has its own ValidationError class
    validation_error = EeEBusinessRegister::Validation::ValidationError.new("Test")
    main_validation_error = EeEBusinessRegister::ValidationError.new("Test")
    
    refute_equal validation_error.class, main_validation_error.class
    assert_equal "EeEBusinessRegister::Validation::ValidationError", validation_error.class.name
    assert_equal "EeEBusinessRegister::ValidationError", main_validation_error.class.name
  end

  # ========================================
  # REAL WORLD USAGE SIMULATION TESTS
  # ========================================

  def test_realistic_authentication_error_scenario
    # Simulate what happens when authentication fails
    begin
      config = EeEBusinessRegister::Configuration.new
      # No credentials set
      client = EeEBusinessRegister::Client.new(config)
      client.call(:lihtandmed_v2, ariregistri_kood: '16863232')
    rescue EeEBusinessRegister::AuthenticationError => e
      assert_includes e.message.downcase, 'configur' # Should mention configuration
    end
  end

  def test_realistic_validation_error_scenario
    # Simulate what happens when validation fails
    begin
      EeEBusinessRegister::Validation.validate_registry_code('invalid')
    rescue EeEBusinessRegister::Validation::ValidationError => e
      assert_includes e.message, 'Invalid registry code format'
      assert_includes e.message, '8 digits'
    end
  end

  def test_realistic_configuration_error_scenario
    # Simulate what happens when configuration validation fails
    begin
      config = EeEBusinessRegister::Configuration.new
      config.username = 'test'
      config.password = 'test'
      config.language = 'invalid_language'
      config.validate!
    rescue EeEBusinessRegister::ConfigurationError => e
      assert_includes e.message, 'Language must be'
      assert_includes e.message, 'eng'
      assert_includes e.message, 'est'
    end
  end
end