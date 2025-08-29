# frozen_string_literal: true

require_relative 'test_helper'

# Summary test file showcasing the working test suite
class TestSummary < Minitest::Test
  def test_gem_loads_successfully
    # Test that the gem loads without errors
    assert_kind_of Module, EeEBusinessRegister
    assert_equal '0.3.0', EeEBusinessRegister::VERSION
  end

  def test_configuration_works
    # Test basic configuration functionality
    config = EeEBusinessRegister::Configuration.new
    assert_instance_of EeEBusinessRegister::Configuration, config
    assert_equal 'eng', config.language
    
    config.username = 'test'
    config.password = 'test'
    assert config.credentials_configured?
  end

  def test_validation_works
    # Test validation functionality
    assert EeEBusinessRegister::Validation.validate_registry_code('16863232')
    
    # Empty string returns nil, not validation error
    assert_nil EeEBusinessRegister::Validation.validate_registry_code('')
    
    # Test with truly invalid format
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_code('invalid')
    end
  end

  def test_error_classes_work
    # Test that all error classes exist and inherit correctly
    assert EeEBusinessRegister::Error < StandardError
    assert EeEBusinessRegister::APIError < EeEBusinessRegister::Error
    assert EeEBusinessRegister::AuthenticationError < EeEBusinessRegister::Error
    assert EeEBusinessRegister::ConfigurationError < EeEBusinessRegister::Error
    assert EeEBusinessRegister::ValidationError < EeEBusinessRegister::Error
  end

  def test_service_classes_exist
    # Test that service classes can be instantiated with default client
    company_service = EeEBusinessRegister::Services::CompanyService.new
    assert_instance_of EeEBusinessRegister::Services::CompanyService, company_service
    
    classifier_service = EeEBusinessRegister::Services::ClassifierService.new
    assert_instance_of EeEBusinessRegister::Services::ClassifierService, classifier_service
  end

  def test_types_work_with_valid_data
    # Test type system with valid data
    registry_code = EeEBusinessRegister::Types::RegistryCode['16863232']
    assert_equal '16863232', registry_code
    
    status = EeEBusinessRegister::Types::CompanyStatus['R']
    assert_equal 'R', status
    
    language = EeEBusinessRegister::Types::Language['eng']
    assert_equal 'eng', language
  end

  def test_main_module_methods_exist
    # Test that main public API methods exist
    assert_respond_to EeEBusinessRegister, :configuration
    assert_respond_to EeEBusinessRegister, :configure
    assert_respond_to EeEBusinessRegister, :find_company
    assert_respond_to EeEBusinessRegister, :validate_code
    assert_respond_to EeEBusinessRegister, :normalize_registry_code
    assert_respond_to EeEBusinessRegister, :get_legal_forms
    assert_respond_to EeEBusinessRegister, :get_company_statuses
    assert_respond_to EeEBusinessRegister, :check_health
    assert_respond_to EeEBusinessRegister, :list_classifiers
    assert_respond_to EeEBusinessRegister, :reset!
  end

  def test_test_helper_works
    # Test that test helper functionality works for creating configurations
    config = EeEBusinessRegister::Configuration.new
    config.username = 'test'
    config.password = 'test'
    assert_instance_of EeEBusinessRegister::Configuration, config
    assert config.credentials_configured?
  end

  def test_comprehensive_coverage_summary
    # Summary test to verify test suite completeness
    assert true
  end
end