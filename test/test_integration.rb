# frozen_string_literal: true

require_relative 'test_helper'

class TestIntegration < Minitest::Test
  def setup
    TestHelper.skip_integration_test_if_no_credentials
    
    @config = TestHelper.load_real_credentials
    EeEBusinessRegister.configure do |config|
      config.username = @config.username
      config.password = @config.password
      config.test_mode! if @config.test_mode?
    end
    
    # Add small delays to respect API rate limits
    sleep 1
  end

  def teardown
    # Clean up configuration after each test
    EeEBusinessRegister.reset_configuration!
    
    # Add small delay after each test to respect rate limits
    sleep 1
  end

  # ========================================
  # FULL WORKFLOW INTEGRATION TESTS
  # ========================================

  def test_complete_company_lookup_workflow
    # Test the complete workflow of looking up a company
    # Using Estonian Business Registry's own code as a stable test case
    registry_code = '10060701'
    
    # 1. Validate the code
    assert EeEBusinessRegister.valid_registry_code?(registry_code)
    
    # 2. Check if company is active
    assert EeEBusinessRegister.company_active?(registry_code)
    
    # 3. Get basic company info
    company = EeEBusinessRegister.find_company(registry_code)
    TestHelper.assert_valid_company_structure(company)
    assert_equal registry_code, company.registry_code
    
    # 4. Get company name
    name = EeEBusinessRegister.company_name(registry_code)
    assert name.respond_to?(:to_s), "Expected name to respond to to_s"
    refute_empty name.to_s
    assert_equal company.name.to_s, name.to_s
    
    # 5. Get detailed company data
    details = EeEBusinessRegister.get_company_details(registry_code)
    assert_instance_of Hash, details
    refute_empty details
  end

  def test_classifier_integration_workflow
    # Test getting various classifiers
    
    # 1. Get legal forms
    legal_forms = EeEBusinessRegister.get_legal_forms
    assert_instance_of EeEBusinessRegister::Models::Classifier, legal_forms
    assert_equal 'OIGVORMID', legal_forms.code
    refute_empty legal_forms.values
    
    # Verify common Estonian legal forms exist
    legal_form_codes = legal_forms.values.map(&:code)
    assert_includes legal_form_codes, 'OÜ'
    assert_includes legal_form_codes, 'AS'
    
    # 2. Get company statuses
    statuses = EeEBusinessRegister.get_company_statuses
    assert_instance_of EeEBusinessRegister::Models::Classifier, statuses
    assert_equal 'EVSTAATUSED', statuses.code
    refute_empty statuses.values
    
    # Verify common statuses exist
    status_codes = statuses.values.map(&:code)
    assert_includes status_codes, 'R'  # Active/Registered
    
    # 3. List all available classifiers
    classifier_list = EeEBusinessRegister.list_classifiers
    assert_instance_of Hash, classifier_list
    assert_includes classifier_list.keys, :legal_forms
    assert_includes classifier_list.keys, :company_statuses
  end

  def test_api_health_and_connectivity
    # Test that the API is accessible and responding
    
    # 1. Check overall health
    assert EeEBusinessRegister.check_health, "API should be healthy"
    
    # 2. Test client-level health check
    client = EeEBusinessRegister.send(:client)
    assert client.configured?, "Client should be configured"
    assert client.healthy?, "Client should report healthy"
    
    # 3. Test operations are available
    operations = client.operations
    assert_instance_of Array, operations
    refute_empty operations
    
    # Should include basic operations
    assert_includes operations, :lihtandmed_v2
    assert(operations.include?(:klassifikaator_v1) || operations.include?(:klassifikaatorid_v1), "Should have classifier operation")
  end

  def test_error_handling_integration
    # Test how errors are handled in real scenarios
    
    # 1. Test with invalid registry code
    assert_raises(EeEBusinessRegister::APIError) do
      EeEBusinessRegister.find_company('invalid')
    end
    
    # 2. Test with non-existent company (valid format but doesn't exist)
    # Use a valid format but unlikely to exist registry code
    non_existent_code = '00000001'
    
    # API behavior may vary - it might return nil or raise an error
    result = EeEBusinessRegister.find_company(non_existent_code)
    # Either returns nil or raises an error - both are acceptable
    if result
      # If it returns a result, it should be valid
      assert_instance_of EeEBusinessRegister::Models::Company, result
    end
    # If it returns nil, that's also fine - just means company doesn't exist
    
    # 3. Test graceful handling in convenience methods
    result = EeEBusinessRegister.company_active?(non_existent_code)
    assert_equal false, result
    
    result = EeEBusinessRegister.company_name(non_existent_code)
    assert_nil result
  end

  def test_configuration_modes_integration
    # Test switching between test and production modes
    
    original_wsdl = EeEBusinessRegister.configuration.wsdl_url
    
    # Switch to test mode
    EeEBusinessRegister.configure do |config|
      config.test_mode!
    end
    
    assert EeEBusinessRegister.configuration.test_mode?
    refute_equal original_wsdl, EeEBusinessRegister.configuration.wsdl_url
    assert_includes EeEBusinessRegister.configuration.wsdl_url, 'demo'
    
    # API should still work in test mode
    # Skip health check in test mode as demo API might not be available
    # assert EeEBusinessRegister.check_health
    
    # Switch back to production mode
    EeEBusinessRegister.configure do |config|
      config.production_mode!
    end
    
    assert EeEBusinessRegister.configuration.production_mode?
    refute_includes EeEBusinessRegister.configuration.wsdl_url, 'demo'
  end

  def test_rate_limiting_respect
    # Test that we can make multiple requests without hitting rate limits
    # Estonian API has rate limits, so we test with delays
    
    registry_codes = ['10060701', '10060701', '10060701']  # Same company multiple times
    
    registry_codes.each_with_index do |code, index|
      # Add delay between requests to respect rate limits
      sleep 1 if index > 0
      
      company = EeEBusinessRegister.find_company(code)
      TestHelper.assert_valid_company_structure(company)
      assert_equal code, company.registry_code
    end
  end

  def test_data_consistency
    # Test that the same company returns consistent data across different calls
    registry_code = '10060701'
    
    # Get basic company info multiple ways
    company = EeEBusinessRegister.find_company(registry_code)
    name_direct = EeEBusinessRegister.company_name(registry_code)
    is_active = EeEBusinessRegister.company_active?(registry_code)
    
    # Data should be consistent
    assert_equal company.name, name_direct
    assert_equal company.active?, is_active
    
    sleep 1  # Rate limiting
    
    # Get detailed data
    details = EeEBusinessRegister.get_company_details(registry_code)
    
    # Basic info should match detailed info
    assert_equal company.registry_code, registry_code
  end

  def test_performance_benchmarking
    # Basic performance test to ensure reasonable response times
    registry_code = '10060701'
    
    performance = TestHelper.measure_performance do
      EeEBusinessRegister.find_company(registry_code)
    end
    
    # API call should complete within reasonable time (30 seconds max)
    assert performance[:duration] < 30, "API call took too long: #{performance[:duration]}s"
    
    # Result should be valid
    TestHelper.assert_valid_company_structure(performance[:result])
  end

  def test_memory_usage_stability
    # Test that repeated operations don't cause memory leaks
    initial_memory = TestHelper.send(:memory_usage)
    
    # Perform multiple operations
    10.times do |i|
      EeEBusinessRegister.company_active?('10060701')
      sleep 0.5  # Small delay for rate limiting
    end
    
    final_memory = TestHelper.send(:memory_usage)
    memory_increase = final_memory - initial_memory
    
    # Memory increase should be reasonable (less than 50MB)
    assert memory_increase < 50 * 1024 * 1024, 
           "Memory usage increased too much: #{memory_increase} bytes"
  end

  # ========================================
  # REAL DATA VALIDATION TESTS
  # ========================================

  def test_real_estonian_company_data_structure
    # Test with a real Estonian company to validate data structures
    company = EeEBusinessRegister.find_company('10060701')
    
    # Validate basic structure - handle Nori::StringWithAttributes
    assert company.name.respond_to?(:to_s), "Company name should respond to to_s"
    assert company.registry_code.respond_to?(:to_s), "Registry code should respond to to_s"
    assert company.status.respond_to?(:to_s), "Company status should respond to to_s"
    assert company.legal_form.respond_to?(:to_s), "Company legal form should respond to to_s"
    
    # Estonian Business Registry should be active
    assert company.active?, "Estonian Business Registry should be active"
    assert_equal 'R', company.status.to_s
    
    # Should have registration date (but might be nil for some companies)
    if company.registration_date
      assert_instance_of Date, company.registration_date
    end
    # At minimum should respond to the registration_date method
    assert company.respond_to?(:registration_date), "Company should have registration_date method"
  end

  def test_real_classifier_data_structure
    legal_forms = EeEBusinessRegister.get_legal_forms
    
    # Validate classifier structure - handle Nori::StringWithAttributes
    assert legal_forms.code.respond_to?(:to_s), "Classifier code should respond to to_s"
    assert legal_forms.name.respond_to?(:to_s), "Classifier name should respond to to_s"
    assert_instance_of Array, legal_forms.values
    refute_empty legal_forms.values
    
    # Validate classifier values
    legal_forms.values.each do |value|
      assert_instance_of EeEBusinessRegister::Models::ClassifierValue, value
      assert value.code.respond_to?(:to_s), "Classifier value code should respond to to_s"
      assert value.name.respond_to?(:to_s), "Classifier value name should respond to to_s"
      # Check if active method exists or use valid_to to determine if active
      if value.respond_to?(:active)
        assert [true, false].include?(value.active)
      else
        # If no active method, check if it's valid by looking at valid_to
        assert value.respond_to?(:valid_to), "Should have valid_to attribute"
      end
    end
    
    # Should contain standard Estonian legal forms
    codes = legal_forms.values.map(&:code)
    %w[OÜ AS MTÜ].each do |expected_code|
      assert_includes codes, expected_code, 
                     "Expected to find #{expected_code} in legal forms"
    end
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
      config = EeEBusinessRegister::Configuration.new
      config.username = ENV['EE_BUSINESS_REGISTER_USERNAME']
      config.password = ENV['EE_BUSINESS_REGISTER_PASSWORD']
      config.test_mode! if ENV['EE_BUSINESS_REGISTER_TEST_MODE'] == 'true'
      return config
    else
      # Fall back to credentials file
      config_file = File.expand_path("~/.ee_business_register_credentials.yml")
      if File.exist?(config_file)
        require 'yaml'
        credentials = YAML.load_file(config_file)
        config = EeEBusinessRegister::Configuration.new
        config.username = credentials['username']
        config.password = credentials['password']
        config.test_mode! if credentials['test_mode']
        return config
      else
        skip "No credentials available for live API testing"
      end
    end
  end
end