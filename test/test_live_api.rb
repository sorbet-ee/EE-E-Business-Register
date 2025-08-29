# frozen_string_literal: true

require_relative 'test_helper'

# Live API tests - these make real calls to the Estonian e-Business Register
class TestLiveApi < Minitest::Test
  def setup
    # Skip all tests if no credentials are available
    skip_unless_credentials_available
    
    # Configure with real credentials
    load_real_credentials
    
    # Add delay to respect API rate limits
    sleep 1
  end

  def teardown
    # Clean up configuration
    EeEBusinessRegister.reset_configuration!
    
    # Add delay to respect rate limits
    sleep 1
  end

  # ========================================
  # CONFIGURATION TESTS
  # ========================================

  def test_api_connectivity
    # Test basic API connectivity
    assert EeEBusinessRegister.check_health, "API should be accessible"
  end

  def test_client_operations_available
    client = EeEBusinessRegister.send(:client)
    operations = client.operations
    
    assert_instance_of Array, operations
    refute_empty operations
    
    # Check for essential operations
    assert_includes operations, :lihtandmed_v2, "Should have company lookup operation"
    # Note: classifier operation might be :klassifikaatorid_v1 instead of :klassifikaator_v1
    assert(operations.include?(:klassifikaator_v1) || operations.include?(:klassifikaatorid_v1), "Should have classifier operation")
  end

  # ========================================
  # COMPANY LOOKUP TESTS
  # ========================================

  def test_find_company_by_registry_code
    # Use Estonian Business Registry's own code as a stable test case
    registry_code = '10060701'
    
    company = EeEBusinessRegister.find_company(registry_code)
    
    assert_instance_of EeEBusinessRegister::Models::Company, company
    assert_equal registry_code, company.registry_code
    assert company.active?, "Estonian Business Registry should be active"
    refute_empty company.name
  end

  def test_find_company_with_invalid_code
    # Test with properly formatted but non-existent code
    non_existent_code = '00000001'
    
    # API may return nil instead of raising error for non-existent companies
    result = EeEBusinessRegister.find_company(non_existent_code)
    assert_nil result
  end

  def test_company_validation
    # Test registry code validation
    assert EeEBusinessRegister.valid_registry_code?('10060701')
    refute EeEBusinessRegister.valid_registry_code?('invalid')
    
    # Test normalization
    normalized = EeEBusinessRegister.normalize_registry_code('10060701')
    assert_equal '10060701', normalized
  end

  # ========================================
  # COMPANY DETAILS TESTS
  # ========================================

  def test_get_company_details
    registry_code = '10060701'
    
    details = EeEBusinessRegister.get_company_details(registry_code)
    
    assert_instance_of Hash, details
    refute_empty details
  end

  def test_company_convenience_methods
    registry_code = '10060701'
    
    # Test convenience methods
    assert EeEBusinessRegister.company_active?(registry_code)
    
    name = EeEBusinessRegister.company_name(registry_code)
    # API might return Nori::StringWithAttributes instead of plain String
    assert name.respond_to?(:to_s)
    assert name.to_s.length > 0
    
    # Company age should be calculable
    age = EeEBusinessRegister.company_age(registry_code)
    assert_instance_of Integer, age if age  # Could be nil if no reg date
  end

  # ========================================
  # CLASSIFIER TESTS
  # ========================================

  def test_get_legal_forms
    legal_forms = EeEBusinessRegister.get_legal_forms
    
    assert_instance_of EeEBusinessRegister::Models::Classifier, legal_forms
    # API might return different classifier codes
    assert legal_forms.code == 'oiguslik_vorm' || legal_forms.code == 'OIGVORMID', "Expected legal forms code to be 'oiguslik_vorm' or 'OIGVORMID', got '#{legal_forms.code}'"
    refute_empty legal_forms.values
    
    # Should contain common Estonian legal forms
    codes = legal_forms.values.map(&:code)
    assert_includes codes, 'OÜ', "Should contain OÜ legal form"
    assert_includes codes, 'AS', "Should contain AS legal form"
  end

  def test_get_company_statuses
    statuses = EeEBusinessRegister.get_company_statuses
    
    assert_instance_of EeEBusinessRegister::Models::Classifier, statuses
    # API might return different classifier codes
    assert statuses.code == 'ariregistri_staatus' || statuses.code == 'EVSTAATUSED', "Expected status code to be 'ariregistri_staatus' or 'EVSTAATUSED', got '#{statuses.code}'"
    refute_empty statuses.values
    
    # Should contain active status
    codes = statuses.values.map(&:code)
    assert_includes codes, 'R', "Should contain 'R' (active) status"
  end

  def test_list_available_classifiers
    classifiers = EeEBusinessRegister.list_classifiers
    
    assert_instance_of Hash, classifiers
    assert_includes classifiers.keys, :legal_forms
    assert_includes classifiers.keys, :company_statuses
    assert_includes classifiers.keys, :regions
  end

  # ========================================
  # SERVICE LEVEL TESTS
  # ========================================

  def test_company_service_direct_access
    service = EeEBusinessRegister.company_service
    assert_instance_of EeEBusinessRegister::Services::CompanyService, service
    
    # Test direct service call
    company = service.find_by_registry_code('10060701')
    assert_instance_of EeEBusinessRegister::Models::Company, company
  end

  def test_classifier_service_direct_access
    service = EeEBusinessRegister.classifier_service
    assert_instance_of EeEBusinessRegister::Services::ClassifierService, service
    
    # Test direct service call
    classifier = service.get_classifier(:legal_forms)
    assert_instance_of EeEBusinessRegister::Models::Classifier, classifier
  end

  # ========================================
  # ERROR HANDLING TESTS
  # ========================================

  def test_invalid_registry_code_validation
    # Test validation at the module level - now returns padded values instead of raising
    result = EeEBusinessRegister.normalize_registry_code('invalid')
    assert_equal '00000000', result
    
    result = EeEBusinessRegister.normalize_registry_code('')
    assert_equal '00000000', result
  end

  def test_graceful_error_handling
    # Test that convenience methods handle errors gracefully
    result = EeEBusinessRegister.company_active?('00000001')
    assert_equal false, result
    
    result = EeEBusinessRegister.company_name('00000001')
    assert_nil result
  end

  # ========================================
  # RATE LIMITING TESTS
  # ========================================

  def test_multiple_requests_with_rate_limiting
    registry_code = '10060701'
    
    # Make several requests with delays
    3.times do |i|
      sleep 1 if i > 0  # Respect rate limits
      
      company = EeEBusinessRegister.find_company(registry_code)
      assert_equal registry_code, company.registry_code
    end
  end

  def test_different_operations_sequential
    # Test different types of operations in sequence
    
    # 1. Company lookup
    company = EeEBusinessRegister.find_company('10060701')
    assert_instance_of EeEBusinessRegister::Models::Company, company
    
    sleep 1  # Rate limiting
    
    # 2. Get legal forms
    legal_forms = EeEBusinessRegister.get_legal_forms
    assert_instance_of EeEBusinessRegister::Models::Classifier, legal_forms
    
    sleep 1  # Rate limiting
    
    # 3. Check health
    assert EeEBusinessRegister.check_health
  end

  private

  def skip_unless_credentials_available
    unless credentials_available?
      skip "Live API tests require credentials. Set environment variables or create ~/.ee_business_register_credentials.yml"
    end
  end

  def credentials_available?
    config_file = File.expand_path("~/.ee_business_register_credentials.yml")
    File.exist?(config_file) || (
      ENV['EE_BUSINESS_REGISTER_USERNAME'] && 
      ENV['EE_BUSINESS_REGISTER_PASSWORD']
    )
  end

  def load_real_credentials
    # Try environment variables first
    if ENV['EE_BUSINESS_REGISTER_USERNAME'] && ENV['EE_BUSINESS_REGISTER_PASSWORD']
      EeEBusinessRegister.configure do |config|
        config.username = ENV['EE_BUSINESS_REGISTER_USERNAME']
        config.password = ENV['EE_BUSINESS_REGISTER_PASSWORD']
        config.test_mode! if ENV['EE_BUSINESS_REGISTER_TEST_MODE'] == 'true'
      end
    else
      # Fall back to credentials file
      config_file = File.expand_path("~/.ee_business_register_credentials.yml")
      if File.exist?(config_file)
        require 'yaml'
        credentials = YAML.load_file(config_file)
        EeEBusinessRegister.configure do |config|
          config.username = credentials['username']
          config.password = credentials['password']
          config.test_mode! if credentials['test_mode']
        end
      else
        skip "No credentials available for live API testing"
      end
    end
  end
end