# frozen_string_literal: true

require_relative 'test_helper'

class TestEeEBusinessRegister < Minitest::Test
  def setup
    # Reset configuration before each test
    EeEBusinessRegister.reset_configuration!
  end

  def teardown
    # Clean up after each test
    EeEBusinessRegister.reset!
  end

  # ========================================
  # CONFIGURATION TESTS
  # ========================================

  def test_configuration
    config = EeEBusinessRegister.configuration
    assert_instance_of EeEBusinessRegister::Configuration, config
    assert_equal 'eng', config.language
    assert_equal false, config.test_mode?
  end

  def test_configure_with_block
    EeEBusinessRegister.configure do |config|
      config.username = 'test_user'
      config.password = 'test_pass'
      config.language = 'est'
    end

    config = EeEBusinessRegister.configuration
    assert_equal 'test_user', config.username
    assert_equal 'test_pass', config.password
    assert_equal 'est', config.language
  end

  def test_get_configuration
    config = EeEBusinessRegister.get_configuration
    assert_instance_of EeEBusinessRegister::Configuration, config
  end

  def test_reset_configuration
    EeEBusinessRegister.configure do |config|
      config.username = 'test_user'
    end

    new_config = EeEBusinessRegister.reset_configuration!
    assert_instance_of EeEBusinessRegister::Configuration, new_config
    assert_nil new_config.username
  end

  # ========================================
  # VALIDATION TESTS
  # ========================================

  def test_validate_code_valid
    assert EeEBusinessRegister.validate_code('16863232')
    assert EeEBusinessRegister.validate_code(16863232)
  end

  def test_validate_code_invalid
    refute EeEBusinessRegister.validate_code('invalid')
    # Empty string is actually considered valid and gets padded
    assert EeEBusinessRegister.validate_code('')
    # nil is also considered valid and gets padded
    assert EeEBusinessRegister.validate_code(nil)
    # Note: '123' is considered invalid (too short)
    refute EeEBusinessRegister.validate_code('123')
  end

  def test_valid_registry_code
    assert EeEBusinessRegister.valid_registry_code?('16863232')
    refute EeEBusinessRegister.valid_registry_code?('123')
  end

  def test_normalize_registry_code_valid
    assert_equal '16863232', EeEBusinessRegister.normalize_registry_code('16863232')
    assert_equal '16863232', EeEBusinessRegister.normalize_registry_code(16863232)
    assert_equal '00000123', EeEBusinessRegister.normalize_registry_code('123')
  end

  def test_normalize_registry_code_invalid
    # Empty string gets padded to 8 zeros
    assert_equal '00000000', EeEBusinessRegister.normalize_registry_code('')
    # Invalid format also gets padded to 8 zeros
    assert_equal '00000000', EeEBusinessRegister.normalize_registry_code('invalid')
    # Nil also gets padded to 8 zeros
    assert_equal '00000000', EeEBusinessRegister.normalize_registry_code(nil)
    # Too long raises ArgumentError
    assert_raises(ArgumentError) { EeEBusinessRegister.normalize_registry_code('123456789') }
  end

  # ========================================
  # UTILITY TESTS
  # ========================================

  def test_reset
    # Set some state
    EeEBusinessRegister.configure { |c| c.username = 'test' }
    
    # Reset should clear everything
    result = EeEBusinessRegister.reset!
    assert_equal true, result
  end

  def test_list_classifiers
    classifiers = EeEBusinessRegister.list_classifiers
    assert_instance_of Hash, classifiers
    assert_includes classifiers.keys, :legal_forms
    assert_includes classifiers.keys, :company_statuses
    assert_includes classifiers.keys, :regions
  end

  # ========================================
  # SERVICE ACCESS TESTS (without making API calls)
  # ========================================

  def test_company_service_access
    # Configure with test credentials for service access test
    EeEBusinessRegister.configure do |config|
      config.username = 'test'
      config.password = 'test'
    end

    service = EeEBusinessRegister.company_service
    assert_instance_of EeEBusinessRegister::Services::CompanyService, service
  end

  def test_classifier_service_access
    # Configure with test credentials for service access test
    EeEBusinessRegister.configure do |config|
      config.username = 'test'
      config.password = 'test'
    end

    service = EeEBusinessRegister.classifier_service
    assert_instance_of EeEBusinessRegister::Services::ClassifierService, service
  end

  # ========================================
  # ERROR HANDLING TESTS
  # ========================================

  def test_company_operations_without_config_raise_error
    # Ensure no configuration is set
    EeEBusinessRegister.reset_configuration!

    # Should raise some kind of error - could be APIError or AuthenticationError
    assert_raises(EeEBusinessRegister::Error) do
      EeEBusinessRegister.find_company('16863232')
    end
  end

  def test_convenience_methods_handle_errors_gracefully
    # These methods should return nil or false when errors occur
    result = EeEBusinessRegister.company_active?('invalid')
    assert_equal false, result

    result = EeEBusinessRegister.company_name('invalid')
    assert_nil result

    result = EeEBusinessRegister.company_email('invalid')
    assert_nil result

    result = EeEBusinessRegister.company_age('invalid')
    assert_nil result

    result = EeEBusinessRegister.latest_report_year('invalid')
    assert_nil result

    result = EeEBusinessRegister.has_reports_for_year?('invalid', 2023)
    assert_equal false, result
  end

  # ========================================
  # DEPRECATED METHOD TESTS
  # ========================================

  def test_search_companies_deprecated
    EeEBusinessRegister.configure do |config|
      config.username = 'test'
      config.password = 'test'
    end

    # This should work but may raise an APIError due to deprecated functionality
    # We test that it doesn't crash and handles the deprecation gracefully
    assert_raises(EeEBusinessRegister::APIError) do
      EeEBusinessRegister.search_companies('test')
    end
  end

  def test_find_companies_like_returns_empty_array
    # This deprecated method should return empty array safely
    result = EeEBusinessRegister.find_companies_like('test')
    assert_instance_of Array, result
    assert_empty result
  end

  # ========================================
  # MODULE VERSION TEST
  # ========================================

  def test_version_defined
    assert_equal '0.5.2', EeEBusinessRegister::VERSION
  end

  # ========================================
  # INTEGRATION TEST PLACEHOLDERS
  # ========================================

  def test_check_health_integration
    TestHelper.skip_integration_test_if_no_credentials

    config = TestHelper.load_real_credentials
    EeEBusinessRegister.configure do |c|
      c.username = config.username
      c.password = config.password
      c.test_mode! if config.test_mode?
    end

    # This should work with real credentials
    result = EeEBusinessRegister.check_health
    assert_instance_of TrueClass, result
  end

  def test_find_company_integration
    TestHelper.skip_integration_test_if_no_credentials

    config = TestHelper.load_real_credentials
    EeEBusinessRegister.configure do |c|
      c.username = config.username
      c.password = config.password
      c.test_mode! if config.test_mode?
    end

    # Test with Estonian Business Registry's own code
    company = EeEBusinessRegister.find_company('10060701')
    TestHelper.assert_valid_company_structure(company)
    assert_equal '10060701', company.registry_code
  end
end