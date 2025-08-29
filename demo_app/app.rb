# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require_relative '../ee_e_business_register/lib/ee_e_business_register'
require 'json'

# Demo application for Estonian e-Business Register API
class EeBusinessRegisterDemo < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  # Configure the gem
  configure do
    EeEBusinessRegister.configure do |config|
      config.username = ENV['EE_API_USERNAME'] || 'test_user'
      config.password = ENV['EE_API_PASSWORD'] || 'test_pass'
      config.language = ENV['EE_API_LANGUAGE'] || 'eng'
      
      # Use test mode if specified
      config.test_mode! if ENV['EE_API_ENVIRONMENT'] == 'test'
      
      # Simple logger for debugging
      config.logger = Logger.new($stdout) if ENV['DEBUG']
    end
  end

  # Home page with API endpoint list
  get '/' do
    @title = 'Estonian e-Business Register API Demo'
    erb :index
  end

  # ==================== COMPANY ENDPOINTS ====================
  
  # Find company by registry code
  get '/company/find' do
    @title = 'Find Company by Registry Code'
    erb :'company/find'
  end

  post '/company/find' do
    @registry_code = params[:registry_code]
    
    begin
      @company = EeEBusinessRegister.find_company(@registry_code)
      @title = "Company: #{@company.name}" if @company
      erb :'company/result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'company/find'
    end
  end

  # Get detailed company data
  get '/company/detailed' do
    @title = 'Get Detailed Company Data'
    erb :'company/detailed'
  end

  post '/company/detailed' do
    @registry_code = params[:registry_code]
    
    begin
      @detailed = EeEBusinessRegister.get_company_details(@registry_code)
      @title = "Detailed Data for #{@registry_code}"
      erb :'company/detailed_result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'company/detailed'
    end
  end

  # ==================== FINANCIAL REPORTS ====================
  
  # Get company documents
  get '/documents' do
    @title = 'Get Company Documents'
    erb :'documents/index'
  end

  post '/documents' do
    @registry_code = params[:registry_code]
    
    begin
      @documents = EeEBusinessRegister.get_documents(@registry_code)
      @title = "Documents: #{@documents.size} found"
      erb :'documents/result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'documents/index'
    end
  end

  # Get annual reports
  get '/reports/annual' do
    @title = 'Get Annual Reports'
    erb :'reports/annual'
  end

  post '/reports/annual' do
    @registry_code = params[:registry_code]
    @year = params[:year].to_i
    
    begin
      @reports = EeEBusinessRegister.get_annual_reports(@registry_code)
      @title = "Annual Reports for #{@registry_code}"
      erb :'reports/annual_result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'reports/annual'
    end
  end

  # Get specific annual report data
  get '/reports/data' do
    @title = 'Get Annual Report Data'
    erb :'reports/data'
  end

  post '/reports/data' do
    @registry_code = params[:registry_code]
    @year = params[:year].to_i
    @report_type = params[:report_type]
    
    begin
      report_type = @report_type.empty? ? 'balance_sheet' : @report_type
      @report_data = EeEBusinessRegister.get_annual_report(@registry_code, @year, type: report_type)
      @title = "Annual Report #{@year} - #{humanize_string(report_type)}"
      erb :'reports/data_result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'reports/data'
    end
  end

  # ==================== REPRESENTATION & OWNERSHIP ====================
  
  # Get representation rights
  get '/representation' do
    @title = 'Get Representation Rights'
    erb :'representation/index'
  end

  post '/representation' do
    @registry_code = params[:registry_code]
    
    begin
      @representation = EeEBusinessRegister.get_representatives(@registry_code)
      @title = "Representatives for #{@registry_code}"
      erb :'representation/result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'representation/index'
    end
  end

  # Get person changes
  get '/person_changes' do
    @title = 'Get Person Changes'
    erb :'person/changes'
  end

  post '/person_changes' do
    @registry_code = params[:registry_code]
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    
    begin
      @changes = EeEBusinessRegister.get_person_changes(
        @registry_code, 
        from: @from_date.empty? ? nil : @from_date,
        to: @to_date.empty? ? nil : @to_date
      )
      @title = "Person Changes for #{@registry_code}"
      erb :'person/changes_result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'person/changes'
    end
  end

  # Beneficial owners form page  
  get '/beneficial_owners' do
    @title = 'Get Beneficial Owners'
    erb :'beneficial_owners/form'
  end

  # Beneficial owners result page
  post '/beneficial_owners' do
    @registry_code = params[:registry_code]
    
    begin
      @owners = EeEBusinessRegister.get_beneficial_owners(@registry_code)
      @title = "Beneficial Owners for #{@registry_code}"
      erb :'beneficial_owners/result'
    rescue => e
      @error = "Error: #{e.message}"
      erb :'beneficial_owners/form'
    end
  end

  # ==================== CLASSIFIERS ====================
  
  # Get classifier data
  get '/classifiers' do
    @title = 'Get Classifier Data'
    @classifier_types = [
      ['Legal Forms', 'legal_forms'],
      ['Company Statuses', 'company_statuses'],
      ['Person Roles', 'person_roles'],
      ['Regions', 'regions'],
      ['Countries', 'countries'],
      ['Report Types', 'report_types'],
      ['Company Subtypes', 'company_subtypes'],
      ['Currencies', 'currencies']
    ]
    erb :'classifiers/index'
  end

  post '/classifiers' do
    @classifier_type = params[:classifier_type]
    
    begin
      @classifier = EeEBusinessRegister.get_classifier(@classifier_type.to_sym)
      @title = "Classifier: #{humanize_string(@classifier_type)}"
      erb :'classifiers/result'
    rescue => e
      @error = "Error: #{e.message}"
      @classifier_types = [
        ['Legal Forms', 'legal_forms'],
        ['Company Statuses', 'company_statuses'],
        ['Person Roles', 'person_roles'],
        ['Regions', 'regions'],
        ['Countries', 'countries'],
        ['Report Types', 'report_types'],
        ['Company Subtypes', 'company_subtypes'],
        ['Currencies', 'currencies']
      ]
      erb :'classifiers/index'
    end
  end

  # ==================== MONITORING & HEALTH ====================
  
  # API health and statistics
  get '/health' do
    @title = 'API Health Status'
    
    begin
      @healthy = EeEBusinessRegister.check_health
      @status_message = @healthy ? "API is accessible and working" : "API is not responding"
    rescue => e
      @healthy = false
      @status_message = "Error checking API health: #{e.message}"
    end
    
    erb :'health/index'
  end

  # ==================== HELPERS ====================
  
  helpers do
    def format_date(date)
      return 'N/A' unless date
      date.respond_to?(:strftime) ? date.strftime('%Y-%m-%d') : date.to_s
    end
    
    def format_money(amount, currency = 'EUR')
      return 'N/A' unless amount
      "#{currency} #{format('%.2f', amount.to_f)}"
    end
    
    def number_to_currency(amount, currency = 'EUR')
      return 'N/A' unless amount
      
      begin
        formatted_amount = amount.to_f
        
        # Format with thousands separator for larger amounts
        if formatted_amount >= 1_000_000
          "#{currency} #{(formatted_amount / 1_000_000).round(2)}M"
        elsif formatted_amount >= 1_000
          "#{currency} #{(formatted_amount / 1_000).round(1)}K"
        else
          "#{currency} #{formatted_amount.round(2)}"
        end
      rescue
        "#{currency} #{amount}"
      end
    end
    
    def format_boolean(value)
      case value
      when true then '✅ Yes'
      when false then '❌ No'
      else 'N/A'
      end
    end
    
    def truncate(text, length = 100)
      return '' unless text
      text.length > length ? "#{text[0...length]}..." : text
    end
    
    def highlight_json(data)
      if data.respond_to?(:to_h)
        JSON.pretty_generate(data.to_h)
      else
        JSON.pretty_generate(data)
      end
    rescue
      data.inspect
    end
    
    def humanize_string(str)
      str.to_s.gsub('_', ' ').split.map(&:capitalize).join(' ')
    end
  end
end