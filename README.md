# 🏛️ Estonian e-Business Register

[![Gem Version](https://badge.fury.io/rb/ee_e_business_register.svg)](https://badge.fury.io/rb/ee_e_business_register)
[![Ruby](https://img.shields.io/badge/Ruby-3.1+-red.svg)](https://www.ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Clean & Simple Ruby client for the Estonian e-Business Register API**

A professional Ruby interface for accessing Estonian company data, following the KISS principle. Built for developers who value simplicity, reliability, and clean code architecture.

**Developed by [Sorbeet Payments OÜ](https://sorbet.ee)** - Estonia's premier FinTech infrastructure company.

---

## ✨ Features

- 🚀 **Simple & Fast** - Clean API with intuitive method names
- 🛡️ **Type Safe** - Immutable data models using dry-struct
- 🌍 **Bilingual** - Estonian and English language support
- 🔍 **Complete Coverage** - Access to all Estonian business data
- 📈 **Production Ready** - Built-in error handling and retry logic
- 🎯 **Developer Friendly** - Comprehensive documentation and examples

---

## 🚀 Quick Start

### Installation

```bash
gem install ee_e_business_register
```

Or add to your Gemfile:

```ruby
gem 'ee_e_business_register'
```

### Basic Setup

```ruby
require 'ee_e_business_register'

# Configure with your Estonian API credentials
EeEBusinessRegister.configure do |config|
  config.username = 'your_username'
  config.password = 'your_password'
end

# Find a company by registry code
company = EeEBusinessRegister.find_company('16863232')
puts company.name          # => "Sorbeet Payments OÜ"
puts company.active?       # => true
puts company.legal_form_text # => "Osaühing"
puts company.email         # => "info@sorbeet.ee"

# Access comprehensive company details
details = EeEBusinessRegister.get_company_details(company.registry_code)
puts details[:general_data] if details[:general_data]
```

---

## 📚 Complete API Reference

### 🏢 Company Operations

#### `find_company(registry_code)`
Get basic company information by 8-digit registry code.

```ruby
# Find a specific company
company = EeEBusinessRegister.find_company('16863232')

puts "Company: #{company.name}"
puts "Status: #{company.active? ? 'Active' : 'Inactive'}"
puts "Legal form: #{company.legal_form_text}"
puts "Registered: #{company.registration_date}"
puts "Email: #{company.email}"
puts "Capital: #{company.capital} #{company.capital_currency}"

# Address information
address = company.address
puts "Address: #{address.full_address}"
puts "County: #{address.county}"
puts "Postal code: #{address.postal_code}"
```

#### Company Search [DEPRECATED]
⚠️ **Company name search is no longer available.** The Estonian e-Business Register removed the company name search operation from their API as of 2024.

```ruby
# This functionality is no longer supported:
# banks = EeEBusinessRegister.search_companies('pank')  # ❌ Will raise APIError

# Use find_company with registry code instead:
company = EeEBusinessRegister.find_company('10060701')  # ✅ Swedbank
```

#### `get_company_details(registry_code)`
Get comprehensive company data including personnel and detailed information.

```ruby
details = EeEBusinessRegister.get_company_details('16863232')
# Returns raw hash with comprehensive data
puts details.inspect
```

### 📄 Documents & Reports

#### `get_annual_reports(registry_code)`
Get list of annual reports filed by a company.

```ruby
reports = EeEBusinessRegister.get_annual_reports('16863232')
reports.each do |report|
  puts "Year #{report[:year]}: #{report[:status]}"
end
```

#### `get_annual_report(registry_code, year, type: 'balance_sheet')`
Get specific annual report data.

```ruby
# Get balance sheet for 2023
report = EeEBusinessRegister.get_annual_report('16863232', 2023)

# Get income statement
income = EeEBusinessRegister.get_annual_report('16863232', 2023, type: 'income_statement')

# Get cash flow statement
cash_flow = EeEBusinessRegister.get_annual_report('16863232', 2023, type: 'cash_flow')
```

#### `get_documents(registry_code)`
Get list of documents filed by a company.

```ruby
documents = EeEBusinessRegister.get_documents('16863232')
documents.each do |doc|
  puts "#{doc[:type]}: #{doc[:name]}"
end
```

### 👥 Personnel & Representation

#### `get_representatives(registry_code)`
Get people authorized to represent the company.

```ruby
reps = EeEBusinessRegister.get_representatives('16863232')
reps.each do |rep|
  puts "#{rep[:name]} - #{rep[:role]}"
end
```

#### `get_person_changes(registry_code, from: nil, to: nil)`
Get personnel changes for a company within a date range.

```ruby
# All changes
changes = EeEBusinessRegister.get_person_changes('16863232')

# Changes since specific date
recent = EeEBusinessRegister.get_person_changes('16863232', from: '2023-01-01')

# Changes in date range
range = EeEBusinessRegister.get_person_changes('16863232', 
  from: '2023-01-01', 
  to: '2023-12-31'
)
```

### 🔍 Reference Data

#### `get_legal_forms()`
Get all available legal form types.

```ruby
forms = EeEBusinessRegister.get_legal_forms
forms.each { |form| puts "#{form[:code]}: #{form[:name]}" }
```

#### `get_company_statuses()`
Get all company status types.

```ruby
statuses = EeEBusinessRegister.get_company_statuses
statuses.each { |status| puts "#{status[:code]}: #{status[:name]}" }
```

#### `get_classifier(type)`
Get any classifier by type.

```ruby
# Available classifier types:
# :legal_forms, :company_statuses, :person_roles, :regions, 
# :countries, :report_types, :company_subtypes, :currencies

regions = EeEBusinessRegister.get_classifier(:regions)
countries = EeEBusinessRegister.get_classifier(:countries)
```

#### `list_classifiers()`
Get descriptions of all available classifiers.

```ruby
EeEBusinessRegister.list_classifiers
# => {
#   legal_forms: "Company legal structures (OÜ, AS, MTÜ, etc.)",
#   company_statuses: "Registration statuses (Active, Liquidation, Deleted)",
#   ...
# }
```

### 🛠️ Utility Methods

#### `check_health()`
Check if the Estonian API is accessible and working.

```ruby
if EeEBusinessRegister.check_health
  puts "✅ Estonian API is working"
else
  puts "❌ Estonian API is not responding"
end
```

#### `validate_code(registry_code)`
Validate if a registry code has the correct format.

```ruby
EeEBusinessRegister.validate_code('16863232')  # => true
EeEBusinessRegister.validate_code('123')       # => false
```

### 🛠️ Beneficial Owners

#### `get_beneficial_owners(registry_code)`
Get beneficial ownership information for a company.

```ruby
owners = EeEBusinessRegister.get_beneficial_owners('16863232')
owners.each do |owner|
  name = "#{owner[:eesnimi]} #{owner[:nimi]}"
  country = owner[:valis_kood_riik_tekstina]
  control = owner[:kontrolli_teostamise_viis_tekstina]
  
  puts "#{name} (#{country}) - #{control}"
end
```

---

## 🏗️ Architecture

### Clean Architecture Design

The gem follows a **clean architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    PUBLIC API                               │
│  EeEBusinessRegister.find_company()                        │
│  EeEBusinessRegister.get_company_details()                 │
│  EeEBusinessRegister.get_beneficial_owners()               │
│  EeEBusinessRegister.get_classifier()                      │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 SERVICE LAYER                               │
│  Services::CompanyService                                   │
│  Services::ClassifierService                               │
│  Services::TrustsService                                   │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 CLIENT LAYER                                │
│  Client (SOAP communication)                               │
│  - Authentication                                          │
│  - Request/Response handling                               │
│  - Retry logic                                             │
│  - Error translation                                       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 DATA MODELS                                 │
│  Models::Company (immutable)                               │
│  Models::Address (immutable)                               │
│  Type-safe with dry-struct                                 │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **Configuration**
Centralized configuration with sensible defaults:

```ruby
EeEBusinessRegister.configure do |config|
  config.username = 'your_username'        # Required: API username
  config.password = 'your_password'        # Required: API password
  config.language = 'eng'                  # 'eng' or 'est' (default: 'eng')
  config.timeout = 30                      # Request timeout in seconds
  config.test_mode = false                 # Use test endpoints
  config.logger = Rails.logger             # Optional logger
end
```

#### 2. **SOAP Client**
Handles all communication with the Estonian API:

- **Authentication**: WSSE username/password authentication
- **Retry Logic**: Automatic retry with exponential backoff for timeouts
- **Error Handling**: Converts SOAP faults to friendly Ruby exceptions
- **Language Support**: Automatically adds language parameter to requests

#### 3. **Service Classes**
Business logic layer that orchestrates API calls and data parsing:

```ruby
# Direct service usage for advanced scenarios
client = EeEBusinessRegister::Client.new
service = EeEBusinessRegister::Services::CompanyService.new(client)
company = service.find_by_registry_code('16863232')
```

#### 4. **Type-Safe Models**
All data returned as immutable, validated structs:

```ruby
company = EeEBusinessRegister.find_company('16863232')

# These are guaranteed types
company.name                    # String
company.active?                 # Boolean  
company.registration_date       # String (YYYY-MM-DD format)
company.address.postal_code     # String or nil
company.capital                 # Float or nil

# Attempting to modify raises an error (immutable)
company.name = "New name"  # => Dry::Struct::Error
```

### Data Flow

1. **Request**: User calls public API method
2. **Validation**: Input parameters are validated and sanitized  
3. **Service**: Appropriate service class handles business logic
4. **Client**: SOAP client makes authenticated request to Estonian API
5. **Parsing**: Raw XML/SOAP response is parsed into structured data
6. **Models**: Data is converted to immutable, type-safe model objects
7. **Response**: Clean, validated data is returned to user

### Error Handling Strategy

The gem uses a hierarchical error handling approach:

```ruby
begin
  company = EeEBusinessRegister.find_company('16863232')
rescue EeEBusinessRegister::ValidationError => e
  puts "Invalid input: #{e.message}"
rescue EeEBusinessRegister::AuthenticationError => e  
  puts "Check credentials: #{e.message}"
rescue EeEBusinessRegister::APIError => e
  puts "API error: #{e.message}"
rescue EeEBusinessRegister::Error => e
  puts "General error: #{e.message}"
end
```

**Error Types:**
- `ValidationError` - Invalid input parameters
- `AuthenticationError` - Invalid API credentials  
- `ConfigurationError` - Missing or invalid configuration
- `APIError` - Estonian API service errors, network issues, timeouts
- `Error` - Base class for all gem errors

---

## 📋 Working Examples

### Example 1: Company Analysis Dashboard

```ruby
require 'ee_e_business_register'

class CompanyAnalyzer
  def initialize
    EeEBusinessRegister.configure do |config|
      config.username = ENV['EE_API_USERNAME']
      config.password = ENV['EE_API_PASSWORD']
      config.language = 'eng'
    end
  end
  
  def analyze_company(registry_code)
    company = EeEBusinessRegister.find_company(registry_code)
    return nil unless company
    
    details = EeEBusinessRegister.get_company_details(registry_code)
    reports = EeEBusinessRegister.get_annual_reports(registry_code)
    
    {
      basic_info: {
        name: company.name,
        status: company.active? ? 'Active' : 'Inactive',
        age_years: EeEBusinessRegister.company_age(registry_code),
        legal_form: company.legal_form_text,
        capital: format_currency(company.capital, company.capital_currency)
      },
      
      location: {
        address: company.address&.full_address,
        county: company.address&.county,
        postal_code: company.address&.postal_code
      },
      
      compliance: {
        latest_report_year: EeEBusinessRegister.latest_report_year(registry_code),
        total_reports: reports&.size || 0,
        has_recent_reports: EeEBusinessRegister.has_reports_for_year?(registry_code, Date.current.year - 1)
      },
      
      contact: {
        email: company.email
      }
    }
  end
  
  def analyze_multiple_companies(registry_codes)
    registry_codes.map do |code|
      begin
        company = EeEBusinessRegister.find_company(code)
        {
          name: company.name,
          registry_code: company.registry_code,
          status: company.active? ? 'Active' : 'Inactive',
          county: company.address&.county,
          legal_form: company.legal_form_text
        }
      rescue => e
        { registry_code: code, error: e.message }
      end
    end
  end
  
  private
  
  def format_currency(amount, currency)
    return 'N/A' unless amount && currency
    "#{currency} #{amount.round(2)}"
  end
end

# Usage
analyzer = CompanyAnalyzer.new
analysis = analyzer.analyze_company('16863232')
puts analysis.inspect

# Analyze multiple companies at once
companies = analyzer.analyze_multiple_companies(['10060701', '16863232', '11051370'])
companies.each { |c| puts "#{c[:name]}: #{c[:status]}" if c[:name] }
```

### Example 2: Compliance Monitor

```ruby
class ComplianceMonitor
  def initialize
    EeEBusinessRegister.configure do |config|
      config.username = ENV['EE_API_USERNAME']
      config.password = ENV['EE_API_PASSWORD']
    end
  end
  
  def check_companies(registry_codes)
    results = []
    
    registry_codes.each do |code|
      begin
        company = EeEBusinessRegister.find_company(code)
        
        if company.nil?
          results << { code: code, status: 'NOT_FOUND', issues: ['Company not found'] }
          next
        end
        
        issues = []
        issues << 'Inactive company' unless company.active?
        issues << 'No email address' if company.email.nil? || company.email.empty?
        issues << 'Old reports' unless has_recent_reports?(code)
        
        results << {
          code: code,
          name: company.name,
          status: company.active? ? 'ACTIVE' : 'INACTIVE',
          issues: issues,
          compliance_score: calculate_compliance_score(company, code)
        }
        
      rescue EeEBusinessRegister::Error => e
        results << { code: code, status: 'ERROR', error: e.message }
      end
    end
    
    results
  end
  
  def generate_report(results)
    active_companies = results.count { |r| r[:status] == 'ACTIVE' }
    total_issues = results.sum { |r| r[:issues]&.size || 0 }
    
    puts "=== COMPLIANCE REPORT ==="
    puts "Total companies checked: #{results.size}"
    puts "Active companies: #{active_companies}"
    puts "Total compliance issues: #{total_issues}"
    puts ""
    
    results.each do |result|
      puts "#{result[:code]}: #{result[:name] || 'N/A'}"
      puts "  Status: #{result[:status]}"
      if result[:issues] && !result[:issues].empty?
        puts "  Issues: #{result[:issues].join(', ')}"
      end
      if result[:compliance_score]
        puts "  Compliance score: #{result[:compliance_score]}/100"
      end
      puts ""
    end
  end
  
  private
  
  def has_recent_reports?(registry_code)
    last_year = Date.current.year - 1
    EeEBusinessRegister.has_reports_for_year?(registry_code, last_year)
  end
  
  def calculate_compliance_score(company, code)
    score = 100
    score -= 30 unless company.active?
    score -= 20 if company.email.nil? || company.email.empty?
    score -= 25 unless has_recent_reports?(code)
    score -= 15 if company.address&.full_address.nil?
    [score, 0].max
  end
end

# Usage
monitor = ComplianceMonitor.new
companies_to_check = ['16863232', '10000001', '12345678']
results = monitor.check_companies(companies_to_check)
monitor.generate_report(results)
```

### Example 3: Beneficial Owners Analyzer

```ruby
class OwnershipAnalyzer
  def initialize
    EeEBusinessRegister.configure do |config|
      config.username = ENV['EE_API_USERNAME']  
      config.password = ENV['EE_API_PASSWORD']
      config.language = 'eng'
    end
  end
  
  def analyze_ownership(registry_code)
    begin
      company = EeEBusinessRegister.find_company(registry_code)
      owners = EeEBusinessRegister.get_beneficial_owners(registry_code)
      
      {
        company: {
          name: company.name,
          registry_code: company.registry_code,
          status: company.active? ? 'Active' : 'Inactive'
        },
        ownership: {
          total_owners: owners.size,
          active_owners: owners.count { |o| !o[:lopp_kpv] },
          foreign_owners: owners.count { |o| o[:valis_kood_riik] != 'EST' },
          control_methods: owners.map { |o| o[:kontrolli_teostamise_viis_tekstina] }.uniq
        },
        owners: owners.map { |owner| format_owner(owner) }
      }
    rescue => e
      { error: e.message, registry_code: registry_code }
    end
  end
  
  def analyze_multiple_companies(registry_codes)
    registry_codes.map { |code| analyze_ownership(code) }
  end
  
  private
  
  def format_owner(owner)
    {
      name: "#{owner[:eesnimi]} #{owner[:nimi]}",
      country: owner[:valis_kood_riik_tekstina] || owner[:aadress_riik_tekstina],
      control_method: owner[:kontrolli_teostamise_viis_tekstina],
      active: !owner[:lopp_kpv],
      period: format_period(owner[:algus_kpv], owner[:lopp_kpv])
    }
  end
  
  def format_period(start_date, end_date)
    start_str = start_date ? start_date.strftime('%Y-%m-%d') : 'Unknown'
    end_str = end_date ? end_date.strftime('%Y-%m-%d') : 'Present'
    "#{start_str} - #{end_str}"
  end
end

# Usage examples
analyzer = OwnershipAnalyzer.new

# Analyze ownership of Swedbank
swedbank_analysis = analyzer.analyze_ownership('10060701')
puts "Company: #{swedbank_analysis[:company][:name]}"
puts "Total owners: #{swedbank_analysis[:ownership][:total_owners]}"
puts "Foreign owners: #{swedbank_analysis[:ownership][:foreign_owners]}"

swedbank_analysis[:owners].each do |owner|
  puts "  #{owner[:name]} (#{owner[:country]}) - #{owner[:control_method]}"
end

# Analyze multiple companies
companies = ['10060701', '16863232', '11051370']  # Swedbank, Sorbeet, Tallinn Airport
results = analyzer.analyze_multiple_companies(companies)

results.each do |result|
  if result[:error]
    puts "Error for #{result[:registry_code]}: #{result[:error]}"
  else
    company = result[:company]
    ownership = result[:ownership]
    puts "#{company[:name]}: #{ownership[:total_owners]} owners, #{ownership[:foreign_owners]} foreign"
  end
end
```

---

## 🔧 Configuration

### Environment Variables

Set up your credentials using environment variables:

```bash
export EE_API_USERNAME="your_username"
export EE_API_PASSWORD="your_password"
export EE_API_LANGUAGE="eng"  # Optional: 'eng' or 'est'
```

### Rails Configuration

For Rails applications, add to `config/initializers/ee_business_register.rb`:

```ruby
EeEBusinessRegister.configure do |config|
  config.username = Rails.application.credentials.dig(:estonian_api, :username)
  config.password = Rails.application.credentials.dig(:estonian_api, :password)
  config.language = 'eng'
  config.timeout = Rails.env.production? ? 30 : 10
  config.logger = Rails.logger
end
```

### Test Mode

For development and testing, enable test mode to use Estonian test endpoints:

```ruby
EeEBusinessRegister.configure do |config|
  config.username = 'test_username'
  config.password = 'test_password'
  config.test_mode!  # Switches to test endpoints
end
```

### All Configuration Options

```ruby
EeEBusinessRegister.configure do |config|
  # Required
  config.username = 'your_username'         # API username
  config.password = 'your_password'         # API password
  
  # Optional  
  config.language = 'eng'                   # Response language: 'eng' or 'est'
  config.timeout = 30                       # Request timeout in seconds
  config.test_mode = false                  # Use test endpoints
  config.logger = Logger.new(STDOUT)       # Custom logger
  
  # WSDL and endpoint URLs (auto-set based on test_mode)
  config.wsdl_url = 'https://ariregxml.rik.ee/schemas/xtee6/arireg.wsdl'
  config.endpoint_url = 'https://ariregxml.rik.ee/cgi-bin/ariregxml'
end

# Check current configuration
config = EeEBusinessRegister.get_configuration
puts "Using language: #{config.language}"
puts "Test mode: #{config.test_mode}"
```

---

## 🔍 Common Use Cases & Walkthroughs

### Walkthrough 1: Basic Company Lookup

The most common use case - looking up a company by registry code:

```ruby
# Step 1: Configure (usually done once in your app initialization)
EeEBusinessRegister.configure do |config|
  config.username = ENV['EE_API_USERNAME']
  config.password = ENV['EE_API_PASSWORD']
end

# Step 2: Look up company
registry_code = '16863232'  # Sorbeet Payments OÜ

# First validate the format (optional but recommended)
unless EeEBusinessRegister.valid_registry_code?(registry_code)
  puts "Invalid registry code format"
  exit
end

# Step 3: Fetch company data
begin
  company = EeEBusinessRegister.find_company(registry_code)
  
  if company
    puts "✅ Found: #{company.name}"
    puts "📍 Address: #{company.address.full_address}"
    puts "📧 Email: #{company.email || 'Not provided'}"
    puts "💰 Capital: #{company.capital} #{company.capital_currency}"
    puts "📅 Registered: #{company.registration_date}"
    puts "⚖️ Legal form: #{company.legal_form_text}"
    puts "🔄 Status: #{company.active? ? 'Active' : 'Inactive'}"
  else
    puts "❌ Company not found"
  end
  
rescue EeEBusinessRegister::Error => e
  puts "Error: #{e.message}"
end
```

### Walkthrough 2: Analyzing Beneficial Ownership

Building an ownership analysis tool with detailed reporting:

```ruby
class OwnershipInvestigator
  def self.investigate(registry_code, options = {})
    # Configure if not already done
    ensure_configured!
    
    puts "🔍 Investigating ownership of #{registry_code}..."
    
    # Get company and ownership data
    company = EeEBusinessRegister.find_company(registry_code)
    owners = EeEBusinessRegister.get_beneficial_owners(registry_code)
    puts "📊 Found #{owners.size} beneficial owners"
    
    # Analyze ownership patterns
    active_owners = owners.reject { |o| o[:lopp_kpv] }
    foreign_owners = owners.select { |o| o[:valis_kood_riik] != 'EST' }
    control_methods = owners.map { |o| o[:kontrolli_teostamise_viis_tekstina] }.uniq
    
    puts "🔋 Active owners: #{active_owners.size}"
    puts "🌍 Foreign owners: #{foreign_owners.size}"
    puts "⚖️ Control methods: #{control_methods.size} different types"
    
    # Apply filters if requested
    filtered_owners = owners
    if options[:active_only]
      filtered_owners = filtered_owners.reject { |o| o[:lopp_kpv] }
      puts "🔍 Filtered to active owners: #{filtered_owners.size}"
    end
    
    if options[:foreign_only]
      filtered_owners = filtered_owners.select { |o| o[:valis_kood_riik] != 'EST' }
      puts "🌍 Filtered to foreign owners: #{filtered_owners.size}"
    end
    
    display_investigation_results(company, filtered_owners, options)
  end
  
  def self.display_investigation_results(company, owners, options = {})
    puts "\n" + "=" * 80
    puts "🏢 COMPANY: #{company.name}"
    puts "📋 Registry Code: #{company.registry_code}"
    puts "🔄 Status: #{company.active? ? '🟢 Active' : '🔴 Inactive'}"
    puts "=" * 80
    
    if owners.empty?
      puts "❌ No beneficial owners found (or none matching filters)"
      return
    end
    
    puts "\n👥 BENEFICIAL OWNERS (#{owners.size}):"
    owners.each_with_index do |owner, index|
      puts "\n#{index + 1}. #{owner[:eesnimi]} #{owner[:nimi]}"
      puts "   🌍 Country: #{owner[:valis_kood_riik_tekstina] || owner[:aadress_riik_tekstina]}"
      puts "   ⚖️ Control: #{owner[:kontrolli_teostamise_viis_tekstina]}"
      
      period_start = owner[:algus_kpv] ? owner[:algus_kpv].strftime('%Y-%m-%d') : 'Unknown'
      period_end = owner[:lopp_kpv] ? owner[:lopp_kpv].strftime('%Y-%m-%d') : 'Present'
      puts "   📅 Period: #{period_start} - #{period_end}"
      
      puts "   🔄 Status: #{owner[:lopp_kpv] ? '🔴 Historical' : '🟢 Active'}"
    end
  end
  
  private
  
  def self.ensure_configured!
    config = EeEBusinessRegister.get_configuration
    return if config.username && config.password
    
    puts "⚠️ Please configure API credentials first:"
    puts "EeEBusinessRegister.configure do |config|"
    puts "  config.username = 'your_username'"
    puts "  config.password = 'your_password'"
    puts "end"
    exit
  end
end

# Usage examples

# Investigate Swedbank ownership
OwnershipInvestigator.investigate('10060701')

# Investigate with filters (active foreign owners only)
OwnershipInvestigator.investigate('10060701', {
  active_only: true,
  foreign_only: true
})
```

### Walkthrough 3: Annual Reports Analysis

Analyzing a company's financial reports:

```ruby
class FinancialAnalyzer
  def self.analyze_company_finances(registry_code)
    ensure_api_health!
    
    puts "📊 Analyzing finances for #{registry_code}..."
    
    # Get basic company info first
    company = EeEBusinessRegister.find_company(registry_code)
    unless company
      puts "❌ Company not found"
      return
    end
    
    puts "🏢 Company: #{company.name}"
    puts "💰 Share capital: #{format_currency(company.capital, company.capital_currency)}"
    
    # Get list of annual reports
    reports = EeEBusinessRegister.get_annual_reports(registry_code)
    
    if reports.empty?
      puts "📄 No annual reports found"
      return
    end
    
    puts "📋 Found #{reports.size} annual reports"
    
    # Analyze recent years
    recent_reports = reports.sort_by { |r| -r[:year].to_i }.first(3)
    
    puts "\n📈 RECENT FINANCIAL HISTORY:"
    puts "=" * 50
    
    recent_reports.each do |report_info|
      year = report_info[:year]
      puts "\n📅 Year #{year}:"
      
      begin
        # Try to get detailed report data
        balance_sheet = EeEBusinessRegister.get_annual_report(
          registry_code, year, type: 'balance_sheet'
        )
        
        income_statement = EeEBusinessRegister.get_annual_report(
          registry_code, year, type: 'income_statement'
        )
        
        puts "  💼 Balance Sheet: Available" if balance_sheet
        puts "  📊 Income Statement: Available" if income_statement
        
        # Display whatever data is available
        if balance_sheet && balance_sheet.is_a?(Hash)
          puts "  📈 Report status: #{report_info[:status] || 'Filed'}"
        end
        
      rescue EeEBusinessRegister::APIError => e
        puts "  ⚠️ Could not fetch detailed data: #{e.message}"
      end
    end
    
    # Check reporting compliance
    current_year = Date.current.year
    last_year = current_year - 1
    
    has_recent = EeEBusinessRegister.has_reports_for_year?(registry_code, last_year)
    latest_year = EeEBusinessRegister.latest_report_year(registry_code)
    
    puts "\n🔍 COMPLIANCE CHECK:"
    puts "  Latest report year: #{latest_year || 'None'}"
    puts "  Has #{last_year} report: #{has_recent ? '✅ Yes' : '❌ No'}"
    
    if latest_year && latest_year < last_year
      puts "  ⚠️ Reporting may be behind schedule"
    elsif has_recent
      puts "  ✅ Reporting appears up to date"
    end
  end
  
  private
  
  def self.ensure_api_health!
    unless EeEBusinessRegister.check_health
      puts "❌ Estonian API is not responding. Please try again later."
      exit
    end
    puts "✅ Estonian API is healthy"
  end
  
  def self.format_currency(amount, currency)
    return 'Not specified' unless amount && currency
    "#{currency} #{amount.round(2)}"
  end
end

# Usage
FinancialAnalyzer.analyze_company_finances('16863232')
```

### Walkthrough 4: Monitoring Company Changes

Setting up monitoring for personnel and other changes:

```ruby
class CompanyMonitor
  def initialize(companies_to_monitor)
    @companies = companies_to_monitor
    ensure_configured!
  end
  
  def check_recent_changes(days_back: 7)
    puts "🔍 Checking for changes in last #{days_back} days..."
    
    from_date = (Date.current - days_back).strftime('%Y-%m-%d')
    to_date = Date.current.strftime('%Y-%m-%d')
    
    @companies.each do |registry_code|
      puts "\n" + "="*60
      puts "🏢 Checking #{registry_code}..."
      
      begin
        company = EeEBusinessRegister.find_company(registry_code)
        unless company
          puts "❌ Company not found"
          next
        end
        
        puts "Company: #{company.name}"
        puts "Status: #{company.active? ? '🟢 Active' : '🔴 Inactive'}"
        
        # Check for personnel changes
        changes = EeEBusinessRegister.get_person_changes(
          registry_code, 
          from: from_date, 
          to: to_date
        )
        
        if changes.empty?
          puts "✅ No personnel changes detected"
        else
          puts "⚠️ Personnel changes found: #{changes.size}"
          changes.each do |change|
            puts "  📝 #{change[:type] || 'Change'}: #{change[:description] || 'Personnel update'}"
            puts "     Date: #{change[:date] || 'Recent'}"
          end
        end
        
        # Check representatives
        reps = EeEBusinessRegister.get_representatives(registry_code)
        puts "👥 Current representatives: #{reps.size}"
        reps.first(3).each do |rep|
          puts "  • #{rep[:name]} (#{rep[:role]})"
        end
        
        # Check recent reports
        latest_year = EeEBusinessRegister.latest_report_year(registry_code)
        if latest_year
          puts "📊 Latest report: #{latest_year}"
        else
          puts "📊 No reports found"
        end
        
      rescue EeEBusinessRegister::Error => e
        puts "❌ Error checking #{registry_code}: #{e.message}"
      end
      
      sleep(1)  # Be nice to the API
    end
  end
  
  def generate_summary
    puts "\n" + "="*60
    puts "📈 MONITORING SUMMARY"
    puts "="*60
    
    active_count = 0
    total_reps = 0
    companies_with_changes = 0
    
    @companies.each do |registry_code|
      begin
        company = EeEBusinessRegister.find_company(registry_code)
        next unless company
        
        active_count += 1 if company.active?
        
        reps = EeEBusinessRegister.get_representatives(registry_code)
        total_reps += reps.size
        
        # Check for any recent changes (simplified)
        changes = EeEBusinessRegister.get_person_changes(registry_code)
        companies_with_changes += 1 unless changes.empty?
        
      rescue EeEBusinessRegister::Error
        # Skip companies with errors for summary
      end
    end
    
    puts "Companies monitored: #{@companies.size}"
    puts "Active companies: #{active_count}"
    puts "Total representatives: #{total_reps}"
    puts "Companies with recent changes: #{companies_with_changes}"
    puts "Average representatives per company: #{(total_reps.to_f / @companies.size).round(1)}"
  end
  
  private
  
  def ensure_configured!
    config = EeEBusinessRegister.get_configuration
    unless config.username && config.password
      raise "API credentials not configured"
    end
  end
end

# Usage
companies_to_watch = ['16863232', '10000001', '12345678']
monitor = CompanyMonitor.new(companies_to_watch)

monitor.check_recent_changes(days_back: 30)
monitor.generate_summary
```

---

## 🐛 Error Handling

### Error Types & Solutions

#### `ValidationError` - Invalid Input
```ruby
begin
  company = EeEBusinessRegister.find_company('invalid-code')
rescue EeEBusinessRegister::ValidationError => e
  puts "Input error: #{e.message}"
  # Solution: Check input format, use validate_code() first
end
```

#### `AuthenticationError` - Credentials Issue  
```ruby
begin
  company = EeEBusinessRegister.find_company('16863232')
rescue EeEBusinessRegister::AuthenticationError => e
  puts "Auth failed: #{e.message}"
  # Solution: Verify username/password, check API account status
end
```

#### `APIError` - Service Issues
```ruby  
begin
  company = EeEBusinessRegister.find_company('16863232')
rescue EeEBusinessRegister::APIError => e
  puts "API error: #{e.message}"
  
  if e.message.include?("timeout")
    # Solution: Retry with longer timeout
    puts "Service is slow, retrying..."
  elsif e.message.include?("not found")
    # Solution: Company doesn't exist
    puts "Company not in register"  
  elsif e.message.include?("rate limit")
    # Solution: Wait before next request
    puts "Too many requests, please wait"
  end
end
```

### Robust Error Handling Pattern

```ruby
class RobustEeClient
  MAX_RETRIES = 3
  
  def self.find_company_safely(registry_code)
    retries = 0
    
    begin
      # Validate input first
      unless EeEBusinessRegister.valid_registry_code?(registry_code)
        return { error: "Invalid registry code format", code: nil }
      end
      
      # Make API call
      company = EeEBusinessRegister.find_company(registry_code)
      
      if company
        { success: true, company: company }
      else
        { error: "Company not found", code: registry_code }  
      end
      
    rescue EeEBusinessRegister::AuthenticationError => e
      { error: "Authentication failed: #{e.message}", code: registry_code }
      
    rescue EeEBusinessRegister::APIError => e
      if e.message.include?("timeout") && retries < MAX_RETRIES
        retries += 1
        puts "Timeout, retrying (#{retries}/#{MAX_RETRIES})..."
        sleep(2 ** retries)  # Exponential backoff
        retry
      else
        { error: "API error: #{e.message}", code: registry_code }
      end
      
    rescue => e
      { error: "Unexpected error: #{e.message}", code: registry_code }
    end
  end
end

# Usage
result = RobustEeClient.find_company_safely('16863232')

if result[:success]
  puts "Found: #{result[:company].name}"
else
  puts "Error: #{result[:error]}"
end
```

---

## 🧪 Testing

### Basic Test Setup

```ruby
# test_helper.rb
require 'minitest/autorun'
require 'ee_e_business_register'

class TestEeBusinessRegister < Minitest::Test
  def setup
    EeEBusinessRegister.configure do |config|
      config.username = 'test_user'
      config.password = 'test_pass'
      config.test_mode!  # Use test endpoints
      config.timeout = 5
    end
  end
end
```

### Example Test Cases

```ruby
class CompanyLookupTest < TestEeBusinessRegister
  def test_find_existing_company
    # Skip if no test credentials
    skip unless test_credentials_available?
    
    company = EeEBusinessRegister.find_company('16863232')
    
    assert_not_nil company
    assert_equal 'Sorbeet Payments OÜ', company.name
    assert company.active?
    assert_match /\d{4}-\d{2}-\d{2}/, company.registration_date
  end
  
  def test_validate_registry_code
    assert EeEBusinessRegister.valid_registry_code?('16863232')
    refute EeEBusinessRegister.valid_registry_code?('123')
    refute EeEBusinessRegister.valid_registry_code?('invalid')
  end
  
  def test_beneficial_owners
    skip unless test_credentials_available?
    
    owners = EeEBusinessRegister.get_beneficial_owners('10060701')  # Swedbank
    
    assert_kind_of Array, owners
    assert owners.size >= 0
    assert owners.all? { |o| o.is_a?(Hash) && o.key?(:eesnimi) && o.key?(:nimi) }
  end
  
  def test_error_handling
    assert_raises(EeEBusinessRegister::ValidationError) do
      EeEBusinessRegister.find_company('invalid')
    end
  end
  
  private
  
  def test_credentials_available?
    config = EeEBusinessRegister.get_configuration
    config.username && config.password
  end
end
```

---

## 📄 License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

---

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

### Development Setup

```bash
git clone https://github.com/angeloskapis/ee_e_business_register.git
cd ee_e_business_register
bundle install
rake test
```

### Code Standards
- Follow Ruby style guide
- Add tests for new features  
- Update documentation
- Keep it simple (KISS principle)

---

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/angeloskapis/ee_e_business_register/issues)
- **Email**: angelos@sorbet.ee
- **Documentation**: [API Reference](https://rubydoc.info/gems/ee_e_business_register)

---

<div align="center">

### 🚀 Ready to get started?

```bash
gem install ee_e_business_register
```

**[⭐ Star us on GitHub](https://github.com/angeloskapis/ee_e_business_register)** if this gem helps your project!

Made with ❤️ in Estonia 🇪🇪 by [Sorbeet Payments OÜ](https://sorbet.ee)

</div>