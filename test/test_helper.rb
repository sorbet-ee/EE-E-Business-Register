# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'
require_relative '../lib/ee_e_business_register/ee_e_business_register'

# Test helper for Estonian e-Business Register gem test suite
class TestHelper
  # Test registry codes for various test scenarios
  TEST_REGISTRY_CODES = {
    valid: '16863232',
    valid_padded: '00000123',
    invalid_short: '123',
    invalid_long: '123456789',
    invalid_letters: '1234567a',
    invalid_empty: '',
    invalid_nil: nil,
    estonian_business_registry: '10060701' # Used for health checks
  }.freeze

  # Test API responses for mocking
  MOCK_COMPANY_RESPONSE = {
    ariregistri_kood: '16863232',
    nimi: 'Sorbeet Payments OÜ',
    staatus: 'R',
    oiguslik_vorm: 'OÜ',
    reg_kuupaev: '2016-08-25',
    aadress: 'Tallinn, Harju maakond',
    email: 'info@sorbeet.ee',
    telefon: '+372 1234567'
  }.freeze

  MOCK_DETAILED_COMPANY_RESPONSE = {
    ariregistri_kood: '16863232',
    nimi: 'Sorbeet Payments OÜ',
    staatus: 'R',
    oiguslik_vorm: 'OÜ',
    reg_kuupaev: '2016-08-25',
    yldandmed: {
      aadress: 'Tallinn, Harju maakond',
      email: 'info@sorbeet.ee',
      telefon: '+372 1234567',
      tegevusalad: ['62010', '62020']
    },
    personal: {
      juhatajad: [
        {
          nimi: 'John Doe',
          isikukood: '39001010000',
          roll: 'Juhataja'
        }
      ]
    }
  }.freeze

  class << self
    # Create a mock configuration for testing
    def mock_configuration
      config = EeEBusinessRegister::Configuration.new
      config.username = 'test_user'
      config.password = 'test_pass'
      config.test_mode!
      config
    end

    # Create a mock client that doesn't make real API calls
    def mock_client
      client = Minitest::Mock.new
      client.expect(:configured?, true)
      client.expect(:healthy?, true)
      client
    end

    # Create a mock successful Savon response
    def mock_savon_response(body)
      response = Minitest::Mock.new
      response.expect(:body, body)
      response.expect(:success?, true)
      response
    end

    # Create a mock error Savon response
    def mock_savon_error_response(error_message)
      response = Minitest::Mock.new
      response.expect(:body, { fault: { faultstring: error_message } })
      response.expect(:success?, false)
      response
    end

    # Skip integration tests if credentials are not configured
    def skip_integration_test_if_no_credentials
      unless credentials_available?
        skip "Integration test skipped: No API credentials configured"
      end
    end

    # Check if API credentials are available for integration tests
    def credentials_available?
      config_file = File.expand_path("~/.ee_business_register_credentials.yml")
      File.exist?(config_file) || (
        ENV['EE_BUSINESS_REGISTER_USERNAME'] && 
        ENV['EE_BUSINESS_REGISTER_PASSWORD']
      )
    end

    # Load real credentials for integration tests
    def load_real_credentials
      config = EeEBusinessRegister::Configuration.new
      
      # Try to load from environment variables first
      if ENV['EE_BUSINESS_REGISTER_USERNAME'] && ENV['EE_BUSINESS_REGISTER_PASSWORD']
        config.username = ENV['EE_BUSINESS_REGISTER_USERNAME']
        config.password = ENV['EE_BUSINESS_REGISTER_PASSWORD']
        config.test_mode! if ENV['EE_BUSINESS_REGISTER_TEST_MODE'] == 'true'
      else
        # Fall back to credentials file
        config_file = File.expand_path("~/.ee_business_register_credentials.yml")
        if File.exist?(config_file)
          require 'yaml'
          credentials = YAML.load_file(config_file)
          config.username = credentials['username']
          config.password = credentials['password']
          config.test_mode! if credentials['test_mode']
        end
      end
      
      config
    end

    # Validate that a response has expected structure
    def assert_valid_company_structure(company)
      raise "Company must respond to :name" unless company.respond_to?(:name)
      raise "Company must respond to :registry_code" unless company.respond_to?(:registry_code)
      raise "Company must respond to :status" unless company.respond_to?(:status)
      raise "Company must respond to :legal_form" unless company.respond_to?(:legal_form)
      raise "Company must respond to :registration_date" unless company.respond_to?(:registration_date)
      true
    end

    # Clean up any test artifacts
    def cleanup_test_artifacts
      # Clean up any temporary files or data created during tests
      temp_files = Dir.glob('test_*.tmp')
      temp_files.each { |file| File.delete(file) if File.exist?(file) }
    end

    # Generate random test data
    def random_registry_code
      format('%08d', rand(10000000..99999999))
    end

    # Measure test performance
    def measure_performance(&block)
      start_time = Time.now
      result = block.call
      end_time = Time.now
      {
        result: result,
        duration: end_time - start_time,
        memory_used: memory_usage
      }
    end

    private

    # Get current memory usage (simplified)
    def memory_usage
      `ps -o rss= -p #{Process.pid}`.to_i * 1024 rescue 0
    end
  end
end

# Make test constants available globally
TEST_CODES = TestHelper::TEST_REGISTRY_CODES