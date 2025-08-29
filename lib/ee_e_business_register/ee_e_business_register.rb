# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "net/http"
require "timeout"

# Ruby compatibility fix: alias the old timeout constant to new ones
Net::TimeoutError = Net::ReadTimeout unless defined?(Net::TimeoutError)

require_relative "ee_e_business_register/version"
require_relative "ee_e_business_register/errors"
require_relative "ee_e_business_register/configuration"
require_relative "ee_e_business_register/validation"
require_relative "ee_e_business_register/types"
require_relative "ee_e_business_register/models/company"
require_relative "ee_e_business_register/models/classifier"
require_relative "ee_e_business_register/models/trust"
require_relative "ee_e_business_register/client"
require_relative "ee_e_business_register/services/company_service"
require_relative "ee_e_business_register/services/classifier_service"
require_relative "ee_e_business_register/services/trusts_service"

# Estonian e-Business Register API Client
#
# A professional Ruby interface for accessing Estonian company data via the official
# e-Business Register SOAP API. Provides type-safe models and comprehensive error handling.
#
# ## Quick Start
#
#   require 'ee_e_business_register'
#
#   # Configure API credentials (required)
#   EeEBusinessRegister.configure do |config|
#     config.username = 'your_api_username'
#     config.password = 'your_api_password'
#   end
#
#   # Find a company by registry code
#   company = EeEBusinessRegister.find_company('16863232')
#   puts company.name          # => "Sorbeet Payments OÜ"
#   puts company.active?       # => true
#   puts company.email         # => "info@sorbeet.ee"
#
module EeEBusinessRegister
  class << self
    # ========================================
    # CONFIGURATION
    # ========================================
    
    def configuration
      @configuration ||= Configuration.new
    end
    
    def configure
      yield(configuration)
      reset_client! # Reset client when configuration changes
    end
    
    # ========================================
    # PRIMARY API - Company Operations
    # ========================================
    
    # Find a company by its registry code
    # 
    # @param code [String, Integer] 8-digit registry code
    # @return [Company] Company object with basic info
    # @raise [ArgumentError] If registry code is invalid
    # @raise [APIError] If company not found or API fails
    # @example
    #   company = EeEBusinessRegister.find_company('16863232')
    #   company = EeEBusinessRegister.find_company(16863232)  # Also accepts integers
    def find_company(code)
      code = normalize_registry_code(code)
      company_service.find_by_registry_code(code)
    end
    
    # Search for companies by name
    #
    # @deprecated This method is no longer functional as the Estonian e-Business Register
    #   has removed the company name search operation from their API. The method will
    #   raise an APIError when called. Use find_company(registry_code) instead.
    #
    # @param query [String] Search query (partial match supported)
    # @param limit [Integer] Max results (default: 10, max: 100)
    # @return [Array<Company>] This method will raise an error
    # @raise [APIError] Always raised - functionality no longer available
    # @example
    #   # This will raise an APIError:
    #   # results = EeEBusinessRegister.search_companies('bank')
    #   
    #   # Use this instead:
    #   company = EeEBusinessRegister.find_company('16863232')
    def search_companies(query, limit: 10)
      company_service.search_by_name(query, limit)
    end
    
    # ========================================
    # DETAILED DATA RETRIEVAL
    # ========================================
    
    # Get comprehensive company details
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [Hash] Complete company data including personnel, addresses, etc.
    # @example
    #   details = EeEBusinessRegister.get_company_details('16863232')
    #   puts details[:general_data][:email]
    #   puts details[:personnel][:board_members]
    def get_company_details(code)
      code = normalize_registry_code(code)
      company_service.get_detailed_data(code)
    end
    
    # Get company's annual reports
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [Array<Hash>] List of annual reports
    # @example
    #   reports = EeEBusinessRegister.get_annual_reports('16863232')
    #   latest = reports.first
    #   puts "Year #{latest[:year]}: #{latest[:status]}"
    def get_annual_reports(code)
      code = normalize_registry_code(code)
      company_service.get_annual_reports(code)
    end
    
    # Get a specific annual report
    #
    # @param code [String, Integer] 8-digit registry code
    # @param year [Integer] Year of the report
    # @param type [String] Report type: 'balance_sheet', 'income_statement', 'cash_flow'
    # @return [Hash] Annual report data
    # @example
    #   report = EeEBusinessRegister.get_annual_report('16863232', 2023)
    #   report = EeEBusinessRegister.get_annual_report('16863232', 2023, type: 'income_statement')
    def get_annual_report(code, year, type: 'balance_sheet')
      code = normalize_registry_code(code)
      company_service.get_annual_report(code, year: year, report_type: type)
    end
    
    # Get company's documents
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [Array<Hash>] List of documents
    # @example
    #   docs = EeEBusinessRegister.get_documents('16863232')
    #   docs.each { |doc| puts "#{doc[:type]}: #{doc[:name]}" }
    def get_documents(code)
      code = normalize_registry_code(code)
      company_service.get_documents(code)
    end
    
    # Get company's representatives (who can legally represent the company)
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [Array<Hash>] List of people with representation rights
    # @example
    #   reps = EeEBusinessRegister.get_representatives('16863232')
    #   reps.each { |rep| puts "#{rep[:name]} - #{rep[:role]}" }
    def get_representatives(code)
      code = normalize_registry_code(code)
      company_service.get_representation(code)
    end
    
    # Get person changes in the company
    #
    # @param code [String, Integer] 8-digit registry code
    # @param from [Date, String] Start date (optional)
    # @param to [Date, String] End date (optional)
    # @return [Array<Hash>] List of person changes
    # @example
    #   changes = EeEBusinessRegister.get_person_changes('16863232')
    #   changes = EeEBusinessRegister.get_person_changes('16863232', from: '2023-01-01')
    def get_person_changes(code, from: nil, to: nil)
      code = normalize_registry_code(code)
      company_service.get_person_changes(code, from_date: from, to_date: to)
    end

    # Get company's beneficial owners
    #
    # @param code [String, Integer] 8-digit registry code  
    # @return [Array<Hash>] List of beneficial owners
    # @example
    #   owners = EeEBusinessRegister.get_beneficial_owners('10060701')
    #   owners.each { |owner| puts "#{owner[:eesnimi]} #{owner[:nimi]} - #{owner[:kontrolli_teostamise_viis_tekstina]}" }
    def get_beneficial_owners(code)
      code = normalize_registry_code(code)
      company_service.get_beneficial_owners(code)
    end
    
    # ========================================
    # REFERENCE DATA (Classifiers)
    # ========================================
    
    # Get list of legal forms (OÜ, AS, MTÜ, etc.)
    #
    # @return [Array<Hash>] List of legal forms with codes and descriptions
    # @example
    #   forms = EeEBusinessRegister.get_legal_forms
    #   forms.each { |f| puts "#{f[:code]}: #{f[:name]}" }
    def get_legal_forms
      classifier_service.get_classifier(:legal_forms)
    end
    
    # Get list of company statuses
    #
    # @return [Array<Hash>] List of statuses (Active, Liquidation, etc.)
    # @example
    #   statuses = EeEBusinessRegister.get_company_statuses
    #   active = statuses.find { |s| s[:code] == 'R' }
    def get_company_statuses
      classifier_service.get_classifier(:company_statuses)
    end
    
    # Get any classifier by type
    #
    # @param type [Symbol, String] Classifier type
    # @return [Array<Hash>] Classifier data
    # @example
    #   regions = EeEBusinessRegister.get_classifier(:regions)
    #   countries = EeEBusinessRegister.get_classifier(:countries)
    def get_classifier(type)
      classifier_service.get_classifier(type)
    end
    
    # List all available classifiers
    #
    # @return [Hash] Map of classifier types to descriptions
    def list_classifiers
      {
        legal_forms: "Company legal structures (OÜ, AS, MTÜ, etc.)",
        company_statuses: "Registration statuses (Active, Liquidation, Deleted)",
        person_roles: "Roles in companies (Board member, Shareholder, etc.)",
        regions: "Estonian administrative regions",
        countries: "Country codes and names",
        report_types: "Annual report classifications",
        company_subtypes: "Detailed company type classifications",
        currencies: "Supported currency codes"
      }
    end
    
    # ========================================
    # UTILITIES & HELPERS
    # ========================================
    
    # Check if the API is accessible and working
    #
    # @return [Boolean] true if API is healthy, false otherwise
    # @example
    #   if EeEBusinessRegister.check_health
    #     puts "API is working!"
    #   end
    def check_health
      client.healthy?
    rescue
      false
    end
    
    # Validate if a registry code has correct format
    #
    # @param code [String, Integer] Registry code to validate
    # @return [Boolean] true if valid format, false otherwise
    # @example
    #   EeEBusinessRegister.validate_code('16863232')  # => true
    #   EeEBusinessRegister.validate_code('123')       # => false
    def validate_code(code)
      Validation.validate_registry_code(code.to_s)
      true
    rescue
      false
    end
    
    # Reset all cached services and clients
    # Useful after configuration changes
    #
    # @return [Boolean] Always returns true
    def reset!
      reset_client!
      @company_service = nil
      @classifier_service = nil
      @trusts_service = nil
      true
    end
    
    # Get current configuration
    #
    # @return [Configuration] Current configuration object
    def get_configuration
      configuration
    end
    
    # ========================================
    # CONVENIENCE METHODS
    # ========================================
    
    # Quick check if company exists and is active
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [Boolean] true if company exists and is active, false otherwise
    # @example
    #   EeEBusinessRegister.company_active?('16863232')  # => true
    def company_active?(code)
      company = find_company(code)
      company&.active? || false
    rescue
      false
    end
    
    # Get company name quickly without full object
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [String, nil] Company name or nil if not found
    # @example
    #   name = EeEBusinessRegister.company_name('16863232')  # => "Sorbeet Payments OÜ"
    def company_name(code)
      company = find_company(code)
      company&.name
    rescue
      nil
    end
    
    # Get company email quickly
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [String, nil] Company email or nil if not found
    # @example
    #   email = EeEBusinessRegister.company_email('16863232')  # => "info@sorbeet.ee"
    def company_email(code)
      company = find_company(code)
      company&.email
    rescue
      nil
    end
    
    # Find companies by partial name match (case-insensitive)
    #
    # @deprecated This method is no longer functional as the Estonian e-Business Register
    #   has removed the company name search operation from their API. This method will
    #   always return an empty array. Use find_company(registry_code) instead.
    #
    # @param query [String] Search query (case-insensitive)
    # @param limit [Integer] Max results (default: 5)
    # @return [Array<Company>] Always returns empty array
    # @example
    #   # This will return an empty array:
    #   # banks = EeEBusinessRegister.find_companies_like('bank')
    #   
    #   # Use this instead:
    #   company = EeEBusinessRegister.find_company('16863232')
    def find_companies_like(query, limit: 5)
      search_companies(query.to_s, limit: limit)
    rescue
      []
    end
    
    # Check if registry code format is valid (doesn't verify existence)
    #
    # @param code [String, Integer] Registry code to check
    # @return [Boolean] true if format is valid, false otherwise
    # @example
    #   EeEBusinessRegister.valid_registry_code?('16863232')  # => true
    #   EeEBusinessRegister.valid_registry_code?('123')       # => false
    def valid_registry_code?(code)
      validate_code(code)
    rescue
      false
    end
    
    # Get latest annual report year for a company
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [Integer, nil] Latest report year or nil if no reports
    # @example
    #   year = EeEBusinessRegister.latest_report_year('16863232')  # => 2023
    def latest_report_year(code)
      reports = get_annual_reports(code)
      return nil if reports.empty?
      
      # Assuming reports are sorted by year, get the most recent
      reports.first[:year]&.to_i
    rescue
      nil
    end
    
    # Check if company has filed reports for a given year
    #
    # @param code [String, Integer] 8-digit registry code
    # @param year [Integer] Year to check
    # @return [Boolean] true if reports exist for that year, false otherwise
    # @example
    #   EeEBusinessRegister.has_reports_for_year?('16863232', 2023)  # => true
    def has_reports_for_year?(code, year)
      reports = get_annual_reports(code)
      reports.any? { |report| report[:year]&.to_i == year.to_i }
    rescue
      false
    end
    
    # Get company age in years (from registration date)
    #
    # @param code [String, Integer] 8-digit registry code
    # @return [Integer, nil] Company age in years or nil if not found
    # @example
    #   age = EeEBusinessRegister.company_age('16863232')  # => 8
    def company_age(code)
      company = find_company(code)
      return nil unless company&.registration_date
      
      registration = Date.parse(company.registration_date)
      ((Date.today - registration) / 365.25).to_i
    rescue
      nil
    end
    
    # Normalize registry code to 8 digits
    #
    # @param code [String, Integer] Registry code to normalize
    # @return [String] Normalized 8-digit code
    # @raise [ArgumentError] If code format is invalid
    # @example
    #   EeEBusinessRegister.normalize_registry_code('123')      # => "00000123"
    #   EeEBusinessRegister.normalize_registry_code(16863232)   # => "16863232"
    def normalize_registry_code(code)
      code = code.to_s.strip.gsub(/\D/, '') # Remove non-digits
      
      # Pad with leading zeros if needed
      code = code.rjust(8, '0') if code.length < 8
      
      unless validate_code(code)
        raise ArgumentError, "Invalid registry code '#{code}'. Estonian registry codes must be exactly 8 digits."
      end
      
      code
    end
    
    # Reset the configuration and cached services
    #
    # @return [Configuration] New configuration instance
    # @example
    #   EeEBusinessRegister.reset_configuration!
    def reset_configuration!
      @configuration = nil
      reset_services!
      configuration
    end
    
    # Reset all cached services
    def reset_services!
      @company_service = nil
      @classifier_service = nil
      @trusts_service = nil
      @client = nil
    end
    
    # Access to company service for testing
    def company_service
      @company_service ||= Services::CompanyService.new(client)
    end
    
    # Access to classifier service for testing  
    def classifier_service
      @classifier_service ||= Services::ClassifierService.new(client)
    end
    
    private
    
    def client
      @client ||= Client.new(configuration)
    end
    
    def reset_client!
      @client = nil
    end
    
    def trusts_service
      @trusts_service ||= Services::TrustsService.new(client)
    end
    
  end
end