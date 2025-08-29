# frozen_string_literal: true

require_relative 'test_helper'

class TestConfiguration < Minitest::Test
  def setup
    @config = EeEBusinessRegister::Configuration.new
  end

  # ========================================
  # INITIALIZATION TESTS
  # ========================================

  def test_initialize_with_defaults
    assert_equal 'https://ariregxmlv6.rik.ee/?wsdl', @config.wsdl_url
    assert_equal 'https://ariregxmlv6.rik.ee/', @config.endpoint_url
    assert_equal 'eng', @config.language
    assert_equal 30, @config.timeout
    assert_equal false, @config.test_mode
    assert_nil @config.logger
    assert_nil @config.username
    assert_nil @config.password
  end

  # ========================================
  # MODE SWITCHING TESTS
  # ========================================

  def test_test_mode
    refute @config.test_mode?
    assert @config.production_mode?

    @config.test_mode!
    assert @config.test_mode?
    refute @config.production_mode?
    assert_equal 'https://demo-ariregxmlv6.rik.ee/?wsdl', @config.wsdl_url
    assert_equal 'https://demo-ariregxmlv6.rik.ee/', @config.endpoint_url
  end

  def test_production_mode
    @config.test_mode!
    assert @config.test_mode?

    @config.production_mode!
    refute @config.test_mode?
    assert @config.production_mode?
    assert_equal 'https://ariregxmlv6.rik.ee/?wsdl', @config.wsdl_url
    assert_equal 'https://ariregxmlv6.rik.ee/', @config.endpoint_url
  end

  # ========================================
  # VALIDATION TESTS
  # ========================================

  def test_validate_without_credentials
    assert_raises(EeEBusinessRegister::ConfigurationError) do
      @config.validate!
    end
  end

  def test_validate_with_empty_username
    @config.username = ''
    @config.password = 'password'

    assert_raises(EeEBusinessRegister::ConfigurationError) do
      @config.validate!
    end
  end

  def test_validate_with_empty_password
    @config.username = 'username'
    @config.password = ''

    assert_raises(EeEBusinessRegister::ConfigurationError) do
      @config.validate!
    end
  end

  def test_validate_with_nil_credentials
    @config.username = nil
    @config.password = 'password'

    assert_raises(EeEBusinessRegister::ConfigurationError) do
      @config.validate!
    end
  end

  def test_validate_with_invalid_language
    @config.username = 'username'
    @config.password = 'password'
    @config.language = 'invalid'

    assert_raises(EeEBusinessRegister::ConfigurationError) do
      @config.validate!
    end
  end

  def test_validate_with_valid_configuration
    @config.username = 'username'
    @config.password = 'password'
    @config.language = 'eng'

    assert @config.validate!
  end

  def test_validate_with_estonian_language
    @config.username = 'username'
    @config.password = 'password'
    @config.language = 'est'

    assert @config.validate!
  end

  # ========================================
  # CREDENTIALS TESTS
  # ========================================

  def test_credentials_configured_false_by_default
    refute @config.credentials_configured?
  end

  def test_credentials_configured_with_username_only
    @config.username = 'username'
    refute @config.credentials_configured?
  end

  def test_credentials_configured_with_password_only
    @config.password = 'password'
    refute @config.credentials_configured?
  end

  def test_credentials_configured_with_both
    @config.username = 'username'
    @config.password = 'password'
    assert @config.credentials_configured?
  end

  def test_credentials_configured_with_empty_strings
    @config.username = ''
    @config.password = ''
    refute @config.credentials_configured?
  end

  def test_credentials_configured_with_mixed_empty
    @config.username = 'username'
    @config.password = ''
    refute @config.credentials_configured?

    @config.username = ''
    @config.password = 'password'
    refute @config.credentials_configured?
  end

  # ========================================
  # ATTRIBUTE ACCESSORS TESTS
  # ========================================

  def test_username_accessor
    assert_nil @config.username
    
    @config.username = 'test_user'
    assert_equal 'test_user', @config.username
  end

  def test_password_accessor
    assert_nil @config.password
    
    @config.password = 'test_pass'
    assert_equal 'test_pass', @config.password
  end

  def test_language_accessor
    assert_equal 'eng', @config.language
    
    @config.language = 'est'
    assert_equal 'est', @config.language
  end

  def test_timeout_accessor
    assert_equal 30, @config.timeout
    
    @config.timeout = 60
    assert_equal 60, @config.timeout
  end

  def test_logger_accessor
    assert_nil @config.logger
    
    require 'logger'
    logger = Logger.new(STDOUT)
    @config.logger = logger
    assert_equal logger, @config.logger
  end

  def test_wsdl_url_accessor
    default_url = 'https://ariregxmlv6.rik.ee/?wsdl'
    assert_equal default_url, @config.wsdl_url
    
    custom_url = 'https://custom.example.com/?wsdl'
    @config.wsdl_url = custom_url
    assert_equal custom_url, @config.wsdl_url
  end

  def test_endpoint_url_accessor
    default_url = 'https://ariregxmlv6.rik.ee/'
    assert_equal default_url, @config.endpoint_url
    
    custom_url = 'https://custom.example.com/'
    @config.endpoint_url = custom_url
    assert_equal custom_url, @config.endpoint_url
  end

  # ========================================
  # TO_HASH TESTS
  # ========================================

  def test_to_h_without_password
    hash = @config.to_h
    
    assert_instance_of Hash, hash
    assert_includes hash.keys, :wsdl_url
    assert_includes hash.keys, :endpoint_url
    assert_includes hash.keys, :language
    assert_includes hash.keys, :timeout
    assert_includes hash.keys, :username
    assert_includes hash.keys, :password
    assert_includes hash.keys, :environment

    assert_nil hash[:password]
    assert_equal 'production', hash[:environment]
  end

  def test_to_h_with_password_masked
    @config.password = 'secret_password'
    hash = @config.to_h
    
    assert_equal '[MASKED]', hash[:password]
  end

  def test_to_h_in_test_mode
    @config.test_mode!
    hash = @config.to_h
    
    assert_equal 'test', hash[:environment]
  end

  def test_to_h_with_all_fields_set
    @config.username = 'test_user'
    @config.password = 'test_pass'
    @config.language = 'est'
    @config.timeout = 45
    @config.test_mode!

    hash = @config.to_h

    assert_equal 'https://demo-ariregxmlv6.rik.ee/?wsdl', hash[:wsdl_url]
    assert_equal 'https://demo-ariregxmlv6.rik.ee/', hash[:endpoint_url]
    assert_equal 'est', hash[:language]
    assert_equal 45, hash[:timeout]
    assert_equal 'test_user', hash[:username]
    assert_equal '[MASKED]', hash[:password]
    assert_equal 'test', hash[:environment]
  end

  # ========================================
  # EDGE CASES AND INTEGRATION TESTS
  # ========================================

  def test_multiple_mode_switches
    # Start in production
    assert @config.production_mode?
    production_wsdl = @config.wsdl_url

    # Switch to test
    @config.test_mode!
    assert @config.test_mode?
    test_wsdl = @config.wsdl_url
    refute_equal production_wsdl, test_wsdl

    # Switch back to production
    @config.production_mode!
    assert @config.production_mode?
    assert_equal production_wsdl, @config.wsdl_url
  end

  def test_configuration_immutable_after_validation
    @config.username = 'username'
    @config.password = 'password'
    
    assert @config.validate!
    
    # Configuration should still be mutable after validation
    @config.language = 'est'
    assert_equal 'est', @config.language
  end
end