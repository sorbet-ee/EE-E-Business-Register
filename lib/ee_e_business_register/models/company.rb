# frozen_string_literal: true

require "dry-struct"

module EeEBusinessRegister
  module Models
    # Estonian business address information
    #
    # Represents a company address as stored in the Estonian e-Business Register.
    # Estonian addresses use a structured format with counties, municipalities,
    # and specific Estonian address system identifiers (ADS codes).
    #
    # The address model supports both human-readable address components and
    # technical identifiers used by the Estonian address system for precise
    # location identification.
    #
    # @example
    #   address = Address.new(
    #     street: "Narva mnt 7",
    #     city: "Tallinn", 
    #     postal_code: "10117",
    #     county: "Harju maakond",
    #     full_address: "Narva mnt 7, 10117 Tallinn, Harju maakond"
    #   )
    #
    class Address < Dry::Struct
      # @!attribute [r] street
      #   @return [String, nil] Street name and building number
      attribute :street, Types::String.optional.default(nil)
      
      # @!attribute [r] city  
      #   @return [String, nil] City or settlement name
      attribute :city, Types::String.optional.default(nil)
      
      # @!attribute [r] postal_code
      #   @return [String, nil] Estonian postal code (5 digits)
      attribute :postal_code, Types::String.optional.default(nil)
      
      # @!attribute [r] county
      #   @return [String, nil] Estonian county (maakond) name
      attribute :county, Types::String.optional.default(nil)
      
      # @!attribute [r] country
      #   @return [String] Country name (defaults to "Estonia")
      attribute :country, Types::String.default("Estonia")
      
      # @!attribute [r] ads_oid
      #   @return [String, nil] Estonian Address Data System object identifier  
      attribute :ads_oid, Types::String.optional.default(nil)
      
      # @!attribute [r] ads_adr_id
      #   @return [String, nil] Estonian Address Data System address identifier
      attribute :ads_adr_id, Types::String.optional.default(nil)
      
      # @!attribute [r] full_address
      #   @return [String, nil] Complete formatted address string
      attribute :full_address, Types::String.optional.default(nil)
    end

    # Estonian company information model
    #
    # Represents a company as registered in the Estonian e-Business Register.
    # Contains all basic company information including identification, legal status,
    # contact details, and business classification data.
    #
    # Estonian companies have unique 8-digit registry codes and follow specific
    # legal forms (OÜ for private limited companies, AS for public companies, etc.).
    # The status field uses single-letter codes: 'R' for active, 'K' for deleted,
    # 'L' and 'N' for liquidation states, 'S' for reorganization.
    #
    # @example
    #   company = Company.new(
    #     name: "Sorbeet Payments OÜ",
    #     registry_code: "16863232", 
    #     status: "R",
    #     legal_form: "OUE",
    #     legal_form_text: "Osaühing"
    #   )
    #   puts company.active?  # => true
    #
    class Company < Dry::Struct
      # @!attribute [r] name
      #   @return [String] Official company name as registered
      attribute :name, Types::String
      
      # @!attribute [r] registry_code  
      #   @return [String] 8-digit Estonian company registry code (unique identifier)
      attribute :registry_code, Types::String
      
      # @!attribute [r] status
      #   @return [String] Single-letter status code (R=Active, K=Deleted, L/N=Liquidation, S=Reorganization)
      attribute :status, Types::String
      
      # @!attribute [r] status_text
      #   @return [String, nil] Human-readable status description
      attribute :status_text, Types::String.optional.default(nil)
      
      # @!attribute [r] legal_form
      #   @return [String, nil] Legal form code (OUE=OÜ, ASE=AS, MTU=MTÜ, etc.)
      attribute :legal_form, Types::String.optional.default(nil)
      
      # @!attribute [r] legal_form_text
      #   @return [String, nil] Human-readable legal form description
      attribute :legal_form_text, Types::String.optional.default(nil)
      
      # @!attribute [r] sub_type
      #   @return [String, nil] Company sub-type classification code
      attribute :sub_type, Types::String.optional.default(nil)
      
      # @!attribute [r] sub_type_text
      #   @return [String, nil] Human-readable sub-type description
      attribute :sub_type_text, Types::String.optional.default(nil)
      
      # @!attribute [r] registration_date
      #   @return [String, nil] Company registration date (YYYY-MM-DD format)
      attribute :registration_date, Types::String.optional.default(nil)
      
      # @!attribute [r] deletion_date
      #   @return [String, nil] Company deletion date if deleted (YYYY-MM-DD format)
      attribute :deletion_date, Types::String.optional.default(nil)
      
      # @!attribute [r] address
      #   @return [Address, nil] Company's registered address
      attribute :address, Address.optional.default(nil)
      
      # @!attribute [r] email
      #   @return [String, nil] Company's registered email address
      attribute :email, Types::String.optional.default(nil)
      
      # @!attribute [r] capital
      #   @return [Float, nil] Company's share capital amount
      attribute :capital, Types::Coercible::Float.optional.default(nil)
      
      # @!attribute [r] capital_currency
      #   @return [String, nil] Currency of the share capital (usually EUR)
      attribute :capital_currency, Types::String.optional.default(nil)
      
      # @!attribute [r] region
      #   @return [String, nil] Estonian region/county code
      attribute :region, Types::String.optional.default(nil)
      
      # @!attribute [r] region_text
      #   @return [String, nil] Human-readable region/county name
      attribute :region_text, Types::String.optional.default(nil)

      # Check if the company is currently active and operating
      #
      # Estonian companies with status 'R' (Registered) are considered active
      # and are legally allowed to conduct business operations.
      #
      # @return [Boolean] true if company status is 'R' (active), false otherwise
      # @example
      #   company.active?  # => true for active companies
      #
      def active?
        status == "R"
      end

      # Check if the company has been deleted/removed from the register
      #
      # Companies with status 'K' (Kustutatud) have been formally deleted
      # from the Estonian Business Register and no longer exist legally.
      #
      # @return [Boolean] true if company status is 'K' (deleted), false otherwise
      # @example
      #   company.deleted?  # => true for deleted companies
      #
      def deleted?
        status == "K"
      end

      # Check if the company is in liquidation process
      #
      # Companies can be in liquidation with status 'L' (Likvideerimisel) or
      # 'N' (different liquidation state). These companies are winding down
      # their operations but still exist legally until liquidation completes.
      #
      # @return [Boolean] true if company is in liquidation, false otherwise
      # @example
      #   company.in_liquidation?  # => true for companies being liquidated
      #
      def in_liquidation?
        status == "L" || status == "N"
      end

      # Check if the company is undergoing reorganization
      #
      # Companies with status 'S' (Sundlõpetamine) are undergoing forced
      # reorganization or restructuring procedures, typically court-ordered.
      #
      # @return [Boolean] true if company status is 'S' (reorganization), false otherwise
      # @example
      #   company.in_reorganization?  # => true for companies in reorganization
      #
      def in_reorganization?
        status == "S"
      end
    end

    # Detailed address information with full Estonian address system data
    class DetailedAddress < Dry::Struct
      attribute :record_id, Types::String.optional
      attribute :card_region, Types::String.optional
      attribute :card_number, Types::String.optional
      attribute :card_type, Types::String.optional
      attribute :entry_number, Types::String.optional
      attribute :ehak_code, Types::String.optional
      attribute :ehak_name, Types::String.optional
      attribute :street_house_apartment, Types::String.optional
      attribute :postal_code, Types::String.optional
      attribute :ads_oid, Types::String.optional
      attribute :ads_adr_id, Types::String.optional
      attribute :full_normalized_address, Types::String.optional
      attribute :start_date, Types::String.optional
      attribute :end_date, Types::String.optional
    end

    # Business activity information (EMTAK codes)
    class BusinessActivity < Dry::Struct
      attribute :record_id, Types::String.optional
      attribute :emtak_code, Types::String.optional
      attribute :emtak_text, Types::String.optional
      attribute :emtak_version, Types::String.optional
      attribute :nace_code, Types::String.optional
      attribute :is_main_activity, Types::Bool.optional
      attribute :start_date, Types::String.optional
      attribute :end_date, Types::String.optional
    end

    # Contact method (phone, email, fax, etc.)
    class ContactMethod < Dry::Struct
      attribute :record_id, Types::String.optional
      attribute :type, Types::String.optional
      attribute :type_text, Types::String.optional
      attribute :value, Types::String.optional
    end

    # Person associated with the company (board member, shareholder, etc.)
    class Person < Dry::Struct
      attribute :record_id, Types::String.optional
      attribute :card_region, Types::String.optional
      attribute :card_number, Types::String.optional
      attribute :card_type, Types::String.optional
      attribute :entry_number, Types::String.optional
      attribute :person_type, Types::String.optional
      attribute :role, Types::String.optional
      attribute :role_text, Types::String.optional
      attribute :first_name, Types::String.optional
      attribute :name_business_name, Types::String.optional
      attribute :personal_registry_code, Types::String.optional
      attribute :address_country, Types::String.optional
      attribute :address_country_text, Types::String.optional
      attribute :address_street, Types::String.optional
      attribute :start_date, Types::String.optional
      attribute :end_date, Types::String.optional
    end

    # General company data (comprehensive information)
    class GeneralData < Dry::Struct
      attribute :first_registration_date, Types::String.optional
      attribute :status, Types::String.optional
      attribute :status_text, Types::String.optional
      attribute :region, Types::String.optional
      attribute :region_text, Types::String.optional
      attribute :region_text_long, Types::String.optional
      attribute :legal_form, Types::String.optional
      attribute :legal_form_number, Types::String.optional
      attribute :legal_form_text, Types::String.optional
      attribute :legal_form_sub_type, Types::String.optional
      attribute :legal_form_sub_type_text, Types::String.optional
      attribute :addresses, Types::Array.of(DetailedAddress).default { [] }
      attribute :business_activities, Types::Array.of(BusinessActivity).default { [] }
      attribute :contact_methods, Types::Array.of(ContactMethod).default { [] }
      attribute :accounting_obligation, Types::Bool.optional
      attribute :founded_without_contribution, Types::Bool.optional
    end

    # Personnel data (people associated with the company)
    class PersonnelData < Dry::Struct
      attribute :registered_persons, Types::Array.of(Person).default { [] }
      attribute :non_registered_persons, Types::Array.of(Person).default { [] }
      attribute :building_society_members, Types::Array.of(Person).default { [] }
      attribute :representation_rights, Types::Any.optional
      attribute :special_representation_conditions, Types::Any.optional
      attribute :pledges_and_transfers, Types::Any.optional
    end

    # Comprehensive detailed company information
    class DetailedCompany < Dry::Struct
      attribute :registry_code, Types::String
      attribute :company_id, Types::String.optional
      attribute :name, Types::String.optional
      attribute :vat_number, Types::String.optional
      attribute :general_data, GeneralData.optional
      attribute :personnel_data, PersonnelData.optional
      attribute :commercial_pledges, Types::Any.optional
      attribute :applications, Types::Any.optional
      attribute :rulings, Types::Any.optional
      attribute :registry_cards, Types::Any.optional

      def active?
        general_data&.status == "R"
      end

      def deleted?
        general_data&.status == "K"
      end

      def in_liquidation?
        status = general_data&.status
        status == "L" || status == "N"
      end

      def in_reorganization?
        general_data&.status == "S"
      end
    end

    # Company document (annual reports, articles of association)
    class CompanyDocument < Dry::Struct
      attribute :document_id, Types::String.optional
      attribute :registry_code, Types::String.optional
      attribute :document_type, Types::String.optional
      attribute :name, Types::String.optional
      attribute :size_bytes, Types::Integer.optional
      attribute :status_date, Types::String.optional
      attribute :validity, Types::String.optional
      attribute :report_type, Types::String.optional
      attribute :accounting_year, Types::String.optional
      attribute :url, Types::String.optional

      # Check if document is valid
      # @return [Boolean] true if document has validity "K" (valid)
      def valid?
        validity == "K"
      end

      # Check if document is expired
      # @return [Boolean] true if document has validity "A" (expired)
      def expired?
        validity == "A"
      end

      # Get human-readable document type description
      # @return [String] Description of document type
      def document_type_description
        case document_type
        when "A"
          "Annual report (PDF)"
        when "D"
          "Annual report (DDOC/BDOC)"
        when "X"
          "Annual report (XBRL)"
        when "P"
          "Articles of association"
        else
          "Unknown document type"
        end
      end

      # Get human-readable report type description
      # @return [String] Description of report type
      def report_type_description
        case report_type
        when "A"
          "Annual report"
        when "P"
          "Final report"
        when "L"
          "Balance sheet prepared upon liquidation"
        when "V"
          "Interim report/balance sheet"
        else
          nil
        end
      end

      # Check if this is an annual report
      # @return [Boolean] true if document type is A, D, or X
      def annual_report?
        ["A", "D", "X"].include?(document_type)
      end

      # Check if this is articles of association
      # @return [Boolean] true if document type is P
      def articles_of_association?
        document_type == "P"
      end

      # Get file size in human-readable format
      # @return [String] File size with appropriate unit
      def human_readable_size
        return "Unknown size" unless size_bytes

        if size_bytes < 1024
          "#{size_bytes} bytes"
        elsif size_bytes < 1024 * 1024
          "#{(size_bytes / 1024.0).round(1)} KB"
        else
          "#{(size_bytes / (1024.0 * 1024)).round(1)} MB"
        end
      end
    end

    # Annual report data entry
    class ReportEntry < Dry::Struct
      attribute :line_number, Types::String.optional.default(nil)
      attribute :line_name, Types::String.optional.default(nil)
      attribute :year_1_value, Types::String.optional.default(nil)
      attribute :year_2_value, Types::String.optional.default(nil)
      attribute :year_3_value, Types::String.optional.default(nil)

      # Get the most recent year's value (usually year_1)
      # @return [String, nil] Most recent value
      def current_value
        year_1_value
      end

      # Get previous year's value (usually year_2)
      # @return [String, nil] Previous year value
      def previous_value
        year_2_value
      end

      # Check if entry has any values
      # @return [Boolean] true if any year has a value
      def has_values?
        [year_1_value, year_2_value, year_3_value].any? { |v| v && !v.strip.empty? }
      end

      # Get numeric value for current year
      # @return [Float, nil] Numeric value or nil if not numeric
      def current_numeric_value
        return nil unless year_1_value
        Float(year_1_value.gsub(/[^\d.-]/, '')) rescue nil
      end

      # Get numeric value for previous year
      # @return [Float, nil] Numeric value or nil if not numeric
      def previous_numeric_value
        return nil unless year_2_value
        Float(year_2_value.gsub(/[^\d.-]/, '')) rescue nil
      end

      # Calculate year-over-year change
      # @return [Float, nil] Percentage change or nil if calculation not possible
      def year_over_year_change
        current = current_numeric_value
        previous = previous_numeric_value
        return nil unless current && previous && previous != 0
        
        ((current - previous) / previous) * 100
      end
    end

    # Annual report data structure
    class AnnualReportData < Dry::Struct
      attribute :registry_code, Types::String
      attribute :report_type, Types::String
      attribute :report_type_description, Types::String.optional.default(nil)
      attribute :financial_year, Types::String.optional.default(nil)
      attribute :entries, Types::Array.of(ReportEntry).default { [] }
      attribute :report_date, Types::String.optional.default(nil)
      attribute :currency, Types::String.optional.default(nil)

      # Get specific report entry by line number
      # @param line_number [String] Line number to find
      # @return [ReportEntry, nil] Found entry or nil
      def find_entry(line_number)
        entries.find { |entry| entry.line_number == line_number.to_s }
      end

      # Get entries that match a pattern in line name
      # @param pattern [Regexp, String] Pattern to match
      # @return [Array<ReportEntry>] Matching entries
      def find_entries_by_name(pattern)
        regex = pattern.is_a?(Regexp) ? pattern : /#{Regexp.escape(pattern.to_s)}/i
        entries.select { |entry| entry.line_name && entry.line_name.match?(regex) }
      end

      # Get all entries with values
      # @return [Array<ReportEntry>] Entries that have at least one value
      def entries_with_values
        entries.select(&:has_values?)
      end

      # Check if this is a balance sheet report
      # @return [Boolean] true for balance sheet report types
      def balance_sheet?
        ["01"].include?(report_type)
      end

      # Check if this is an income statement report
      # @return [Boolean] true for income statement report types
      def income_statement?
        ["02"].include?(report_type)
      end

      # Check if this is a cash flow statement report
      # @return [Boolean] true for cash flow statement report types
      def cash_flow_statement?
        ["04"].include?(report_type)
      end

      # Get report type description based on code
      # @return [String] Human-readable report type
      def report_type_description
        case report_type
        when "01"
          "Balance Sheet"
        when "02"
          "Income Statement"
        when "03"
          "Statement of Changes in Equity"
        when "04"
          "Cash Flow Statement"
        when "05"
          "Notes to Financial Statements"
        when "06"
          "Management Report"
        when "07"
          "Auditor's Report"
        when "08"
          "Profit Distribution Proposal"
        when "09"
          "Decision on Profit Distribution"
        when "10"
          "Consolidated Balance Sheet"
        when "11"
          "Consolidated Income Statement"
        when "12"
          "Consolidated Statement of Changes in Equity"
        when "13"
          "Consolidated Cash Flow Statement"
        when "14"
          "Notes to Consolidated Financial Statements"
        when "15"
          "Consolidated Management Report"
        else
          "Report Type #{report_type}"
        end
      end
    end

    # Person with representation rights
    class RepresentationPerson < Dry::Struct
      attribute :personal_code, Types::String.optional.default(nil)
      attribute :personal_code_country, Types::String.optional.default(nil)
      attribute :personal_code_country_text, Types::String.optional.default(nil)
      attribute :birth_date, Types::String.optional.default(nil)
      attribute :first_name, Types::String.optional.default(nil)
      attribute :last_name, Types::String.optional.default(nil)
      attribute :role, Types::String.optional.default(nil)
      attribute :role_text, Types::String.optional.default(nil)
      attribute :exclusive_representation_rights, Types::String.optional.default(nil)
      attribute :representation_exceptions, Types::String.optional.default(nil)

      # Get person's full name
      # @return [String] Combined first and last name
      def full_name
        [first_name, last_name].compact.join(" ")
      end

      # Check if person has exclusive representation rights
      # @return [Boolean] true if person has exclusive representation rights
      def has_exclusive_representation_rights?
        exclusive_representation_rights == "JAH"
      end

      # Check if person is Estonian citizen
      # @return [Boolean] true if personal code country is EST
      def estonian_citizen?
        personal_code_country == "EST"
      end

      # Check if person is a natural person (has personal code)
      # @return [Boolean] true if personal code is present
      def natural_person?
        !personal_code.nil? && !personal_code.empty?
      end

      # Check if person is a legal entity (no personal code or institutional code)
      # @return [Boolean] true if appears to be a legal entity
      def legal_entity?
        !natural_person? || personal_code_country == "XXX"
      end

      # Get role type category
      # @return [Symbol] Role category
      def role_category
        case role
        when "ASES"
          :authorized_representative
        when "KOAS"
          :higher_authority
        when "JJUH", "JJLI"
          :board_member
        when "OSAS", "OSLI"  
          :shareholder
        when "VANM"
          :parent_company
        else
          :other
        end
      end

      # Check if person is a board member
      # @return [Boolean] true if role indicates board membership
      def board_member?
        role_category == :board_member
      end

      # Check if person is a shareholder
      # @return [Boolean] true if role indicates shareholding
      def shareholder?
        role_category == :shareholder
      end

      # Check if person is an authorized representative
      # @return [Boolean] true if role indicates authorized representation
      def authorized_representative?
        role_category == :authorized_representative
      end
    end

    # Company representation rights information
    class CompanyRepresentation < Dry::Struct
      attribute :registry_code, Types::String
      attribute :business_name, Types::String.optional.default(nil)
      attribute :status, Types::String.optional.default(nil)
      attribute :status_text, Types::String.optional.default(nil)
      attribute :legal_form, Types::String.optional.default(nil)
      attribute :legal_form_text, Types::String.optional.default(nil)
      attribute :representation_exceptions, Types::String.optional.default(nil)
      attribute :persons, Types::Array.of(RepresentationPerson).default { [] }

      # Check if company is active
      # @return [Boolean] true if company status is active
      def active?
        status == "R"
      end

      # Get all persons with exclusive representation rights
      # @return [Array<RepresentationPerson>] Persons with exclusive rights
      def persons_with_exclusive_rights
        persons.select(&:has_exclusive_representation_rights?)
      end

      # Get all board members
      # @return [Array<RepresentationPerson>] Board members
      def board_members
        persons.select(&:board_member?)
      end

      # Get all shareholders
      # @return [Array<RepresentationPerson>] Shareholders  
      def shareholders
        persons.select(&:shareholder?)
      end

      # Get all authorized representatives
      # @return [Array<RepresentationPerson>] Authorized representatives
      def authorized_representatives
        persons.select(&:authorized_representative?)
      end

      # Get all natural persons (individuals)
      # @return [Array<RepresentationPerson>] Natural persons
      def natural_persons
        persons.select(&:natural_person?)
      end

      # Get all legal entities
      # @return [Array<RepresentationPerson>] Legal entities
      def legal_entities
        persons.select(&:legal_entity?)
      end

      # Get all Estonian citizens
      # @return [Array<RepresentationPerson>] Estonian citizens
      def estonian_citizens
        persons.select(&:estonian_citizen?)
      end

      # Check if there are any representation exceptions or limitations
      # @return [Boolean] true if representation exceptions exist
      def has_representation_exceptions?
        !representation_exceptions.nil? && !representation_exceptions.empty?
      end

      # Get persons by role
      # @param role_code [String] Role code (e.g., "ASES", "JJUH")
      # @return [Array<RepresentationPerson>] Persons with specified role
      def persons_by_role(role_code)
        persons.select { |person| person.role == role_code }
      end

      # Find person by personal code
      # @param personal_code [String] Personal identification code
      # @return [RepresentationPerson, nil] Found person or nil
      def find_person_by_code(personal_code)
        persons.find { |person| person.personal_code == personal_code }
      end

      # Find persons by name (case-insensitive partial match)
      # @param name [String] Name to search for
      # @return [Array<RepresentationPerson>] Matching persons
      def find_persons_by_name(name)
        return [] if name.nil? || name.empty?
        
        search_term = name.downcase
        persons.select do |person|
          full_name_lower = person.full_name.downcase
          person.first_name&.downcase&.include?(search_term) ||
          person.last_name&.downcase&.include?(search_term) ||
          full_name_lower.include?(search_term)
        end
      end

      # Get representation structure summary
      # @return [Hash] Summary of representation structure
      def representation_summary
        {
          total_persons: persons.size,
          natural_persons: natural_persons.size,
          legal_entities: legal_entities.size,
          board_members: board_members.size,
          shareholders: shareholders.size,
          authorized_representatives: authorized_representatives.size,
          persons_with_exclusive_rights: persons_with_exclusive_rights.size,
          estonian_citizens: estonian_citizens.size,
          has_exceptions: has_representation_exceptions?
        }
      end
    end

    # Individual person change record
    class PersonChange < Dry::Struct
      attribute :person_role, Types::String.optional.default(nil)
      attribute :person_role_text, Types::String.optional.default(nil)
      attribute :change_type, Types::String.optional.default(nil)
      attribute :change_time, Types::String.optional.default(nil)
      attribute :old_person_id, Types::String.optional.default(nil)
      attribute :new_person_id, Types::String.optional.default(nil)

      # Get human-readable change type description
      # @return [String] Description of the change type
      def change_type_description
        case change_type&.to_s
        when "1"
          "Person Added"
        when "2"
          "Person Removed"
        when "3"
          "Person Data Changed"
        else
          "Unknown Change Type"
        end
      end

      # Check if this is an addition change
      # @return [Boolean] true if change type is 1 (added)
      def addition?
        change_type&.to_s == "1"
      end

      # Check if this is a removal change
      # @return [Boolean] true if change type is 2 (removed)
      def removal?
        change_type&.to_s == "2"
      end

      # Check if this is a data change
      # @return [Boolean] true if change type is 3 (changed)
      def data_change?
        change_type&.to_s == "3"
      end

      # Check if this involves a beneficial owner
      # @return [Boolean] true if person role is "W"
      def beneficial_owner_change?
        person_role == "W"
      end

      # Get the relevant person ID based on change type
      # @return [String, nil] Person ID that's most relevant for this change
      def relevant_person_id
        case change_type&.to_s
        when "1"  # Addition - use new ID
          new_person_id
        when "2"  # Removal - use old ID
          old_person_id
        when "3"  # Change - prefer new ID, fallback to old
          new_person_id || old_person_id
        else
          new_person_id || old_person_id
        end
      end

      # Parse change time to DateTime if available
      # @return [DateTime, nil] Parsed change time or nil
      def change_time_parsed
        return nil unless change_time
        DateTime.parse(change_time) rescue nil
      end

      # Get change severity level for monitoring
      # @return [Symbol] Severity level (:high, :medium, :low)
      def change_severity
        if beneficial_owner_change?
          case change_type&.to_s
          when "1", "2"  # Addition or removal of beneficial owner
            :high
          when "3"       # Change to beneficial owner data
            :medium
          else
            :low
          end
        else
          :low
        end
      end
    end

    # Company with person changes
    class CompanyWithChanges < Dry::Struct
      attribute :registry_code, Types::String
      attribute :business_name, Types::String.optional.default(nil)
      attribute :legal_form, Types::String.optional.default(nil)
      attribute :legal_form_text, Types::String.optional.default(nil)
      attribute :status, Types::String.optional.default(nil)
      attribute :status_text, Types::String.optional.default(nil)
      attribute :person_changes, Types::Array.of(PersonChange).default { [] }

      # Check if company is active
      # @return [Boolean] true if company status is active
      def active?
        status == "R"
      end

      # Get all addition changes
      # @return [Array<PersonChange>] Changes where persons were added
      def additions
        person_changes.select(&:addition?)
      end

      # Get all removal changes
      # @return [Array<PersonChange>] Changes where persons were removed
      def removals
        person_changes.select(&:removal?)
      end

      # Get all data changes
      # @return [Array<PersonChange>] Changes where person data was modified
      def data_changes
        person_changes.select(&:data_change?)
      end

      # Get all beneficial owner changes
      # @return [Array<PersonChange>] Changes involving beneficial owners
      def beneficial_owner_changes
        person_changes.select(&:beneficial_owner_change?)
      end

      # Get changes by severity level
      # @param level [Symbol] Severity level (:high, :medium, :low)
      # @return [Array<PersonChange>] Changes matching the severity level
      def changes_by_severity(level)
        person_changes.select { |change| change.change_severity == level }
      end

      # Get high-priority changes (beneficial owner additions/removals)
      # @return [Array<PersonChange>] High-priority changes
      def high_priority_changes
        changes_by_severity(:high)
      end

      # Check if there are any high-priority changes
      # @return [Boolean] true if any high-priority changes exist
      def has_high_priority_changes?
        high_priority_changes.any?
      end

      # Get changes by person role
      # @param role [String] Person role code (e.g., "W", "JJUH")
      # @return [Array<PersonChange>] Changes for the specified role
      def changes_by_role(role)
        person_changes.select { |change| change.person_role == role }
      end

      # Get unique person roles that had changes
      # @return [Array<String>] Unique person role codes
      def changed_roles
        person_changes.map(&:person_role).compact.uniq
      end

      # Get changes within a time range
      # @param start_time [DateTime, String] Start of time range
      # @param end_time [DateTime, String] End of time range
      # @return [Array<PersonChange>] Changes within the time range
      def changes_in_time_range(start_time, end_time)
        start_dt = start_time.is_a?(String) ? DateTime.parse(start_time) : start_time
        end_dt = end_time.is_a?(String) ? DateTime.parse(end_time) : end_time
        
        person_changes.select do |change|
          change_dt = change.change_time_parsed
          change_dt && change_dt >= start_dt && change_dt <= end_dt
        end
      rescue ArgumentError
        []  # Return empty array if date parsing fails
      end

      # Get summary of changes
      # @return [Hash] Summary statistics
      def changes_summary
        {
          total_changes: person_changes.size,
          additions: additions.size,
          removals: removals.size,
          data_changes: data_changes.size,
          beneficial_owner_changes: beneficial_owner_changes.size,
          high_priority_changes: high_priority_changes.size,
          changed_roles: changed_roles.size,
          roles_affected: changed_roles
        }
      end
    end

    # Person changes query results with pagination
    class PersonChanges < Dry::Struct
      attribute :companies, Types::Array.of(CompanyWithChanges).default { [] }
      attribute :total_results, Types::Integer.default(0)
      attribute :page, Types::Integer.default(1)
      attribute :results_per_page, Types::Integer.default(100)
      attribute :change_date, Types::String.optional.default(nil)
      attribute :person_roles_searched, Types::Array.of(Types::String).default { [] }
      attribute :change_types_searched, Types::Array.of(Types::String).default { [] }

      # Check if there are more pages available
      # @return [Boolean] true if more pages exist
      def has_more_pages?
        total_companies_pages > page
      end

      # Calculate total number of pages
      # @return [Integer] Total pages available
      def total_companies_pages
        return 1 if results_per_page <= 0
        (total_results.to_f / results_per_page).ceil
      end

      # Get next page number
      # @return [Integer, nil] Next page number or nil if on last page
      def next_page
        has_more_pages? ? page + 1 : nil
      end

      # Get previous page number  
      # @return [Integer, nil] Previous page number or nil if on first page
      def previous_page
        page > 1 ? page - 1 : nil
      end

      # Check if this is the first page
      # @return [Boolean] true if on page 1
      def first_page?
        page == 1
      end

      # Check if this is the last page
      # @return [Boolean] true if on the last page
      def last_page?
        page >= total_companies_pages
      end

      # Get all companies with high-priority changes
      # @return [Array<CompanyWithChanges>] Companies with high-priority changes
      def companies_with_high_priority_changes
        companies.select(&:has_high_priority_changes?)
      end

      # Get all companies with beneficial owner changes
      # @return [Array<CompanyWithChanges>] Companies with beneficial owner changes
      def companies_with_beneficial_owner_changes
        companies.select { |company| company.beneficial_owner_changes.any? }
      end

      # Get companies by change type
      # @param change_type [String, Integer] Change type to filter by
      # @return [Array<CompanyWithChanges>] Companies with the specified change type
      def companies_by_change_type(change_type)
        type_str = change_type.to_s
        companies.select do |company|
          company.person_changes.any? { |change| change.change_type == type_str }
        end
      end

      # Get all addition changes across all companies
      # @return [Array<PersonChange>] All addition changes
      def all_additions
        companies.flat_map(&:additions)
      end

      # Get all removal changes across all companies
      # @return [Array<PersonChange>] All removal changes
      def all_removals
        companies.flat_map(&:removals)
      end

      # Get all data changes across all companies
      # @return [Array<PersonChange>] All data changes
      def all_data_changes
        companies.flat_map(&:data_changes)
      end

      # Get overall summary across all companies
      # @return [Hash] Overall summary statistics
      def overall_summary
        total_changes = companies.sum { |company| company.person_changes.size }
        
        {
          companies_with_changes: companies.size,
          total_changes: total_changes,
          additions: all_additions.size,
          removals: all_removals.size,
          data_changes: all_data_changes.size,
          beneficial_owner_changes: companies.sum { |c| c.beneficial_owner_changes.size },
          high_priority_changes: companies.sum { |c| c.high_priority_changes.size },
          companies_with_high_priority: companies_with_high_priority_changes.size,
          page_info: {
            current_page: page,
            total_pages: total_companies_pages,
            results_per_page: results_per_page,
            total_results: total_results
          }
        }
      end

      # Get changes for a specific date range (if change times are available)
      # @param start_time [DateTime, String] Start of time range
      # @param end_time [DateTime, String] End of time range  
      # @return [Array<PersonChange>] All changes within the time range
      def changes_in_time_range(start_time, end_time)
        companies.flat_map { |company| company.changes_in_time_range(start_time, end_time) }
      end

      # Find company by registry code
      # @param registry_code [String] Company registry code
      # @return [CompanyWithChanges, nil] Found company or nil
      def find_company(registry_code)
        companies.find { |company| company.registry_code == registry_code }
      end

      # Get unique person roles that had changes across all companies
      # @return [Array<String>] Unique person role codes
      def all_changed_roles
        companies.flat_map(&:changed_roles).uniq
      end
    end

    # Represents a beneficial owner of a company.
    #
    # Beneficial owners are natural persons who ultimately own or control
    # a company through various means (shareholding, voting rights, management).
    # This information is critical for AML compliance and transparency.
    class BeneficialOwner < Dry::Struct
      attribute :entry_id, Types::String.optional.default(nil)
      attribute :first_name, Types::String.optional.default(nil)
      attribute :last_name, Types::String.optional.default(nil)
      attribute :personal_code, Types::String.optional.default(nil)
      attribute :foreign_id_code, Types::String.optional.default(nil)
      attribute :birth_date, Types::String.optional.default(nil)
      attribute :id_country, Types::String.optional.default(nil)
      attribute :id_country_text, Types::String.optional.default(nil)
      attribute :residence_country, Types::String.optional.default(nil)
      attribute :residence_country_text, Types::String.optional.default(nil)
      attribute :control_type, Types::String.optional.default(nil)
      attribute :control_type_text, Types::String.optional.default(nil)
      attribute :ending_type, Types::String.optional.default(nil)
      attribute :ending_type_text, Types::String.optional.default(nil)
      attribute :start_date, Types::String.optional.default(nil)
      attribute :end_date, Types::String.optional.default(nil)
      attribute :discrepancy_notice, Types::Bool.default(false)

      # Get full name of beneficial owner
      # @return [String] Combined first and last name
      def full_name
        [first_name, last_name].compact.join(" ")
      end

      # Check if beneficial owner has a discrepancy notice
      # @return [Boolean] True if discrepancy notice exists
      def discrepancy_notice?
        discrepancy_notice == true
      end

      # Check if beneficial owner is currently active (no end date)
      # @return [Boolean] True if owner is currently active
      def active?
        end_date.nil? || end_date.empty?
      end

      # Parse start date to Date object
      # @return [Date, nil] Parsed start date or nil
      def start_date_parsed
        return nil if start_date.nil? || start_date.empty?
        Date.parse(start_date.sub(/Z$/, ''))
      rescue Date::Error
        nil
      end

      # Parse end date to Date object
      # @return [Date, nil] Parsed end date or nil
      def end_date_parsed
        return nil if end_date.nil? || end_date.empty?
        Date.parse(end_date.sub(/Z$/, ''))
      rescue Date::Error
        nil
      end

      # Get control type category for compliance analysis
      # @return [Symbol] Control type category (:ownership, :management, :other)
      def control_category
        case control_type
        when "X" then :ownership  # >50% voting rights
        when "J" then :management # Board/council member
        when "K" then :ownership  # >25% shareholding
        when "M" then :other      # Other control means
        else :other
        end
      end

      # Check if owner is foreign (non-Estonian)
      # @return [Boolean] True if owner is foreign
      def foreign?
        !foreign_id_code.nil? && !foreign_id_code.empty?
      end

      # Get ownership duration in days
      # @return [Integer, nil] Days of ownership or nil if still active
      def ownership_duration_days
        return nil if start_date_parsed.nil?
        end_date = end_date_parsed || Date.today
        (end_date - start_date_parsed).to_i
      rescue
        nil
      end
    end

    # Container for beneficial owners query results.
    #
    # Provides comprehensive information about a company's beneficial
    # ownership structure including statistics and compliance indicators.
    class BeneficialOwners < Dry::Struct
      attribute :registry_code, Types::String.optional.default(nil)
      attribute :required_to_submit, Types::Bool.default(false)
      attribute :total_count, Types::Integer.default(0)
      attribute :hidden_count, Types::Integer.default(0)
      attribute :no_discrepancy_notice, Types::Bool.default(false)
      attribute :beneficial_owners, Types::Array.of(BeneficialOwner).default([].freeze)

      # Check if company is required to submit beneficial owners
      # @return [Boolean] True if submission is required
      def submission_required?
        required_to_submit == true
      end

      # Check if any discrepancy notices exist
      # @return [Boolean] True if discrepancy notices exist
      def discrepancy_notice_exists?
        no_discrepancy_notice == false
      end

      # Get count of visible (non-hidden) beneficial owners
      # @return [Integer] Number of visible owners
      def visible_count
        total_count - hidden_count
      end

      # Get currently active beneficial owners
      # @return [Array<BeneficialOwner>] Active owners
      def active_owners
        beneficial_owners.select(&:active?)
      end

      # Get historical (inactive) beneficial owners
      # @return [Array<BeneficialOwner>] Inactive owners
      def inactive_owners
        beneficial_owners.reject(&:active?)
      end

      # Get owners with discrepancy notices
      # @return [Array<BeneficialOwner>] Owners with notices
      def owners_with_discrepancies
        beneficial_owners.select(&:discrepancy_notice?)
      end

      # Group owners by control category
      # @return [Hash<Symbol, Array<BeneficialOwner>>] Grouped owners
      def by_control_category
        beneficial_owners.group_by(&:control_category)
      end

      # Get foreign beneficial owners
      # @return [Array<BeneficialOwner>] Foreign owners
      def foreign_owners
        beneficial_owners.select(&:foreign?)
      end

      # Get domestic (Estonian) beneficial owners
      # @return [Array<BeneficialOwner>] Domestic owners
      def domestic_owners
        beneficial_owners.reject(&:foreign?)
      end

      # Calculate compliance score (0-100)
      # Higher score indicates better compliance
      # @return [Integer] Compliance score
      def compliance_score
        score = 100
        score -= 20 if !submission_required? && beneficial_owners.empty?
        score -= 15 if discrepancy_notice_exists?
        score -= 10 if hidden_count > 0
        score -= 10 if beneficial_owners.empty? && submission_required?
        score -= 5 * owners_with_discrepancies.size
        [score, 0].max
      end

      # Generate compliance summary
      # @return [Hash] Compliance summary statistics
      def compliance_summary
        {
          submission_required: submission_required?,
          total_owners: total_count,
          visible_owners: visible_count,
          hidden_owners: hidden_count,
          active_owners: active_owners.size,
          inactive_owners: inactive_owners.size,
          foreign_owners: foreign_owners.size,
          domestic_owners: domestic_owners.size,
          discrepancy_notices: owners_with_discrepancies.size,
          compliance_score: compliance_score,
          by_control_type: by_control_category.transform_values(&:size)
        }
      end
    end

    # Represents a change entry for a company.
    #
    # Each entry describes a specific type of change that occurred
    # in the company's registry data on a particular date.
    class ChangeEntry < Dry::Struct
      attribute :registry_card_area, Types::String.optional.default(nil)
      attribute :card_type, Types::String.optional.default(nil)
      attribute :registry_card_number, Types::String.optional.default(nil)
      attribute :entry_number, Types::String.optional.default(nil)
      attribute :entry_type, Types::String.optional.default(nil)
      attribute :entry_type_text, Types::String.optional.default(nil)
      attribute :changed_data_type, Types::String.optional.default(nil)

      # Check if this entry represents a personnel change
      # @return [Boolean] True if entry is personnel-related
      def personnel_change?
        entry_type_text&.downcase&.include?("isik") || 
        changed_data_type&.downcase&.include?("isik")
      end

      # Check if this entry represents a communication change
      # @return [Boolean] True if entry is communication-related
      def communication_change?
        changed_data_type&.downcase&.include?("side") ||
        changed_data_type&.downcase&.include?("kontakt")
      end

      # Check if this entry represents an activity change
      # @return [Boolean] True if entry is activity-related
      def activity_change?
        changed_data_type&.downcase&.include?("tegevus") ||
        changed_data_type&.downcase&.include?("emtak")
      end

      # Check if this entry represents an address change
      # @return [Boolean] True if entry is address-related
      def address_change?
        changed_data_type&.downcase&.include?("aadress")
      end

      # Get change category for analysis
      # @return [Symbol] Category of change (:personnel, :communication, :activity, :address, :other)
      def change_category
        return :personnel if personnel_change?
        return :communication if communication_change?
        return :activity if activity_change?
        return :address if address_change?
        :other
      end
    end

    # Represents a company with its changes on a specific date.
    #
    # Contains the company's basic information and all the changes
    # that occurred on the queried date.
    class CompanyChange < Dry::Struct
      attribute :registry_code, Types::String.optional.default(nil)
      attribute :business_name, Types::String.optional.default(nil)
      attribute :legal_form, Types::String.optional.default(nil)
      attribute :entries, Types::Array.of(ChangeEntry).default([].freeze)
      attribute :non_entered_persons, Types::String.optional.default(nil)
      attribute :communication_means, Types::String.optional.default(nil)
      attribute :activity_fields, Types::String.optional.default(nil)

      # Get total number of changes for this company
      # @return [Integer] Number of change entries
      def total_changes
        entries.size
      end

      # Check if company has personnel changes
      # @return [Boolean] True if any personnel changes exist
      def has_personnel_changes?
        entries.any?(&:personnel_change?) || !non_entered_persons.nil?
      end

      # Check if company has communication changes
      # @return [Boolean] True if any communication changes exist
      def has_communication_changes?
        entries.any?(&:communication_change?) || !communication_means.nil?
      end

      # Check if company has activity changes
      # @return [Boolean] True if any activity changes exist
      def has_activity_changes?
        entries.any?(&:activity_change?) || !activity_fields.nil?
      end

      # Check if company has address changes
      # @return [Boolean] True if any address changes exist
      def has_address_changes?
        entries.any?(&:address_change?)
      end

      # Group entries by change category
      # @return [Hash<Symbol, Array<ChangeEntry>>] Grouped entries
      def entries_by_category
        entries.group_by(&:change_category)
      end

      # Get all change categories for this company
      # @return [Array<Symbol>] Unique change categories
      def change_categories
        categories = entries.map(&:change_category)
        categories << :personnel if !non_entered_persons.nil?
        categories << :communication if !communication_means.nil?
        categories << :activity if !activity_fields.nil?
        categories.uniq
      end

      # Generate summary of changes
      # @return [Hash] Change summary with counts
      def changes_summary
        by_category = entries_by_category
        {
          total_changes: total_changes,
          personnel_changes: (by_category[:personnel]&.size || 0) + (non_entered_persons ? 1 : 0),
          communication_changes: (by_category[:communication]&.size || 0) + (communication_means ? 1 : 0),
          activity_changes: (by_category[:activity]&.size || 0) + (activity_fields ? 1 : 0),
          address_changes: by_category[:address]&.size || 0,
          other_changes: by_category[:other]&.size || 0,
          categories: change_categories.size
        }
      end
    end

    # Container for company changes query results.
    #
    # Provides access to all companies that had changes on a specific date
    # along with pagination and filtering capabilities.
    class CompanyChanges < Dry::Struct
      attribute :change_date, Types::String.optional.default(nil)
      attribute :companies, Types::Array.of(CompanyChange).default([].freeze)
      attribute :total_count, Types::Integer.default(0)
      attribute :page, Types::Integer.default(1)
      attribute :results_per_page, Types::Integer.default(500)

      # Check if there are more pages available
      # @return [Boolean] True if more pages exist
      def has_more_pages?
        (page * results_per_page) < total_count
      end

      # Calculate total number of pages
      # @return [Integer] Total pages available
      def total_pages
        (total_count.to_f / results_per_page).ceil
      end

      # Get next page number
      # @return [Integer, nil] Next page number or nil if last page
      def next_page
        has_more_pages? ? page + 1 : nil
      end

      # Get companies with specific types of changes
      # @param category [Symbol] Change category (:personnel, :communication, :activity, :address)
      # @return [Array<CompanyChange>] Filtered companies
      def companies_with_changes(category)
        case category
        when :personnel
          companies.select(&:has_personnel_changes?)
        when :communication
          companies.select(&:has_communication_changes?)
        when :activity
          companies.select(&:has_activity_changes?)
        when :address
          companies.select(&:has_address_changes?)
        else
          []
        end
      end

      # Group companies by the types of changes they have
      # @return [Hash<Symbol, Array<CompanyChange>>] Companies grouped by change type
      def companies_by_change_type
        {
          personnel: companies_with_changes(:personnel),
          communication: companies_with_changes(:communication),
          activity: companies_with_changes(:activity),
          address: companies_with_changes(:address)
        }
      end

      # Find company by registry code
      # @param registry_code [String] Company registry code
      # @return [CompanyChange, nil] Found company or nil
      def find_company(registry_code)
        companies.find { |c| c.registry_code == registry_code }
      end

      # Get companies with multiple types of changes
      # @param min_categories [Integer] Minimum number of change categories (default: 2)
      # @return [Array<CompanyChange>] Companies with diverse changes
      def companies_with_multiple_changes(min_categories: 2)
        companies.select { |c| c.change_categories.size >= min_categories }
      end

      # Generate summary statistics for all changes
      # @return [Hash] Comprehensive change statistics
      def summary
        all_changes = companies.flat_map(&:entries)
        by_category = all_changes.group_by(&:change_category)
        
        {
          change_date: change_date,
          total_companies: companies.size,
          total_changes: all_changes.size,
          companies_with_personnel_changes: companies_with_changes(:personnel).size,
          companies_with_communication_changes: companies_with_changes(:communication).size,
          companies_with_activity_changes: companies_with_changes(:activity).size,
          companies_with_address_changes: companies_with_changes(:address).size,
          companies_with_multiple_changes: companies_with_multiple_changes.size,
          changes_by_category: by_category.transform_values(&:size),
          pagination: {
            current_page: page,
            total_pages: total_pages,
            results_per_page: results_per_page,
            total_results: total_count,
            has_more: has_more_pages?
          }
        }
      end
    end

    # Represents a status change for a court ruling.
    #
    # Each change tracks when and how a ruling's status was modified
    # throughout its lifecycle (signed, enforced, etc.).
    class RulingStatusChange < Dry::Struct
      attribute :change_id, Types::String.optional.default(nil)
      attribute :status, Types::String.optional.default(nil)
      attribute :status_text, Types::String.optional.default(nil)
      attribute :change_date, Types::String.optional.default(nil)

      # Parse change date to Time object
      # @return [Time, nil] Parsed change date or nil
      def change_date_parsed
        return nil if change_date.nil? || change_date.empty?
        Time.parse(change_date)
      rescue ArgumentError
        nil
      end

      # Check if this is a final status change (enforced)
      # @return [Boolean] True if status indicates enforcement
      def final_status?
        status == "J" || status_text&.downcase&.include?("jõustunud")
      end
    end

    # Represents a registry entry.
    #
    # Registry entries document various changes and updates
    # made to a company's information in the business register.
    class Entry < Dry::Struct
      attribute :entry_number, Types::String.optional.default(nil)
      attribute :entry_date, Types::String.optional.default(nil)
      attribute :entry_type, Types::String.optional.default(nil)
      attribute :entry_type_text, Types::String.optional.default(nil)
      attribute :ruling_number, Types::String.optional.default(nil)
      attribute :ruling_date, Types::String.optional.default(nil)
      attribute :ruling_type, Types::String.optional.default(nil)
      attribute :ruling_type_text, Types::String.optional.default(nil)
      attribute :ruling_status, Types::String.optional.default(nil)
      attribute :ruling_status_text, Types::String.optional.default(nil)
      attribute :card_number, Types::String.optional.default(nil)
      attribute :card_type, Types::String.optional.default(nil)

      # Parse entry date to Time object
      # @return [Time, nil] Parsed entry date or nil
      def entry_date_parsed
        return nil if entry_date.nil? || entry_date.empty?
        Time.parse(entry_date)
      rescue ArgumentError
        nil
      end

      # Parse ruling date to Time object
      # @return [Time, nil] Parsed ruling date or nil
      def ruling_date_parsed
        return nil if ruling_date.nil? || ruling_date.empty?
        Time.parse(ruling_date)
      rescue ArgumentError
        nil
      end

      # Check if this entry has an associated ruling
      # @return [Boolean] True if ruling information exists
      def has_ruling?
        !ruling_number.nil? && !ruling_number.empty?
      end

      # Check if the associated ruling is enforced
      # @return [Boolean] True if ruling status indicates enforcement
      def ruling_enforced?
        ruling_status == "J" || ruling_status_text&.downcase&.include?("jõustunud")
      end

      # Get entry category for analysis
      # @return [Symbol] Entry category (:modification, :registration, :liquidation, :other)
      def entry_category
        return :other unless entry_type_text
        
        text = entry_type_text.downcase
        return :modification if text.include?("muutmis") || text.include?("muudatus")
        return :registration if text.include?("registreeri") || text.include?("kanne")
        return :liquidation if text.include?("likvideeri") || text.include?("lõpetami")
        :other
      end
    end

    # Represents a court ruling.
    #
    # Court rulings are official decisions that affect company
    # registration, modifications, or legal proceedings.
    class Ruling < Dry::Struct
      attribute :entry_number, Types::String.optional.default(nil)
      attribute :entry_date, Types::String.optional.default(nil)
      attribute :entry_type, Types::String.optional.default(nil)
      attribute :entry_type_text, Types::String.optional.default(nil)
      attribute :ruling_number, Types::String.optional.default(nil)
      attribute :ruling_date, Types::String.optional.default(nil)
      attribute :ruling_type, Types::String.optional.default(nil)
      attribute :ruling_type_text, Types::String.optional.default(nil)
      attribute :ruling_status, Types::String.optional.default(nil)
      attribute :ruling_status_text, Types::String.optional.default(nil)
      attribute :ruling_status_date, Types::String.optional.default(nil)
      attribute :additional_deadline, Types::String.optional.default(nil)
      attribute :card_number, Types::String.optional.default(nil)
      attribute :card_type, Types::String.optional.default(nil)
      attribute :status_changes, Types::Array.of(RulingStatusChange).default([].freeze)

      # Parse entry date to Time object
      # @return [Time, nil] Parsed entry date or nil
      def entry_date_parsed
        return nil if entry_date.nil? || entry_date.empty?
        Time.parse(entry_date)
      rescue ArgumentError
        nil
      end

      # Parse ruling date to Time object
      # @return [Time, nil] Parsed ruling date or nil
      def ruling_date_parsed
        return nil if ruling_date.nil? || ruling_date.empty?
        Time.parse(ruling_date)
      rescue ArgumentError
        nil
      end

      # Parse ruling status date to Time object
      # @return [Time, nil] Parsed status date or nil
      def ruling_status_date_parsed
        return nil if ruling_status_date.nil? || ruling_status_date.empty?
        Time.parse(ruling_status_date)
      rescue ArgumentError
        nil
      end

      # Parse additional deadline to Time object
      # @return [Time, nil] Parsed deadline or nil
      def additional_deadline_parsed
        return nil if additional_deadline.nil? || additional_deadline.empty?
        Time.parse(additional_deadline)
      rescue ArgumentError
        nil
      end

      # Check if ruling is enforced
      # @return [Boolean] True if ruling status indicates enforcement
      def enforced?
        ruling_status == "J" || ruling_status_text&.downcase&.include?("jõustunud")
      end

      # Check if ruling is signed
      # @return [Boolean] True if ruling status indicates signing
      def signed?
        ruling_status == "D" || ruling_status_text&.downcase&.include?("allkirjastatud")
      end

      # Check if ruling has additional deadline
      # @return [Boolean] True if additional deadline exists
      def has_additional_deadline?
        !additional_deadline.nil? && !additional_deadline.empty?
      end

      # Get most recent status change
      # @return [RulingStatusChange, nil] Latest status change or nil
      def latest_status_change
        return nil if status_changes.empty?
        
        status_changes.max_by do |change|
          change.change_date_parsed || Time.at(0)
        end
      end

      # Get ruling processing duration (entry to enforcement)
      # @return [Float, nil] Duration in days or nil
      def processing_duration_days
        entry_time = entry_date_parsed
        status_time = ruling_status_date_parsed
        
        return nil unless entry_time && status_time
        
        (status_time - entry_time) / (24 * 60 * 60)  # Convert seconds to days
      end

      # Get ruling type category
      # @return [Symbol] Ruling category (:entry, :procedural, :other)
      def ruling_category
        return :other unless ruling_type
        
        case ruling_type.upcase
        when "K1" then :entry      # Entry ruling
        when "U2" then :procedural # Procedural ruling
        else :other
        end
      end
    end

    # Represents a company with its entries and rulings.
    #
    # Contains company information along with all entries and rulings
    # for a specific time period query.
    class CompanyWithEntriesRulings < Dry::Struct
      attribute :company_id, Types::String.optional.default(nil)
      attribute :business_name, Types::String.optional.default(nil)
      attribute :legal_form, Types::String.optional.default(nil)
      attribute :legal_form_text, Types::String.optional.default(nil)
      attribute :legal_form_subtype, Types::String.optional.default(nil)
      attribute :legal_form_subtype_text, Types::String.optional.default(nil)
      attribute :registry_code, Types::String.optional.default(nil)
      attribute :status, Types::String.optional.default(nil)
      attribute :status_text, Types::String.optional.default(nil)
      attribute :entries, Types::Array.of(Entry).default([].freeze)
      attribute :rulings, Types::Array.of(Ruling).default([].freeze)

      # Get total number of entries
      # @return [Integer] Number of entries
      def total_entries
        entries.size
      end

      # Get total number of rulings
      # @return [Integer] Number of rulings
      def total_rulings
        rulings.size
      end

      # Get enforced rulings
      # @return [Array<Ruling>] Enforced rulings
      def enforced_rulings
        rulings.select(&:enforced?)
      end

      # Get pending rulings (not yet enforced)
      # @return [Array<Ruling>] Pending rulings
      def pending_rulings
        rulings.reject(&:enforced?)
      end

      # Get entries by category
      # @return [Hash<Symbol, Array<Entry>>] Grouped entries
      def entries_by_category
        entries.group_by(&:entry_category)
      end

      # Get rulings by category
      # @return [Hash<Symbol, Array<Ruling>>] Grouped rulings
      def rulings_by_category
        rulings.group_by(&:ruling_category)
      end

      # Check if company has any enforced rulings
      # @return [Boolean] True if any rulings are enforced
      def has_enforced_rulings?
        rulings.any?(&:enforced?)
      end

      # Check if company has any pending rulings
      # @return [Boolean] True if any rulings are pending
      def has_pending_rulings?
        rulings.any? { |r| !r.enforced? }
      end

      # Get average ruling processing time
      # @return [Float, nil] Average days or nil if no data
      def average_ruling_processing_days
        durations = rulings.map(&:processing_duration_days).compact
        return nil if durations.empty?
        
        durations.sum / durations.size.to_f
      end

      # Check if company is currently registered
      # @return [Boolean] True if status indicates registration
      def registered?
        status == "R" || status_text&.downcase&.include?("registrisse kantud")
      end

      # Generate summary of company's legal activity
      # @return [Hash] Activity summary with statistics
      def legal_activity_summary
        {
          total_entries: total_entries,
          total_rulings: total_rulings,
          enforced_rulings: enforced_rulings.size,
          pending_rulings: pending_rulings.size,
          registered: registered?,
          entries_by_category: entries_by_category.transform_values(&:size),
          rulings_by_category: rulings_by_category.transform_values(&:size),
          average_processing_days: average_ruling_processing_days&.round(1)
        }
      end
    end

    # Represents a single annual report listing entry.
    #
    # Contains metadata about available annual reports for a company,
    # including report type, financial year, and period information.
    class AnnualReportListing < Dry::Struct
      attribute :report_code, Types::String.optional.default(nil)
      attribute :report_name, Types::String.optional.default(nil)
      attribute :accounting_year, Types::String.optional.default(nil)
      attribute :financial_year_start, Types::String.optional.default(nil)
      attribute :financial_year_end, Types::String.optional.default(nil)

      # Parse financial year start to Date object
      # @return [Date, nil] Parsed start date or nil
      def financial_year_start_parsed
        return nil if financial_year_start.nil? || financial_year_start.empty?
        Date.parse(financial_year_start.sub(/Z$/, ''))
      rescue Date::Error
        nil
      end

      # Parse financial year end to Date object
      # @return [Date, nil] Parsed end date or nil
      def financial_year_end_parsed
        return nil if financial_year_end.nil? || financial_year_end.empty?
        Date.parse(financial_year_end.sub(/Z$/, ''))
      rescue Date::Error
        nil
      end

      # Get financial year period description
      # @return [String] Human-readable period description
      def financial_year_period
        return accounting_year.to_s unless financial_year_start && financial_year_end
        
        start_date = financial_year_start_parsed
        end_date = financial_year_end_parsed
        
        if start_date && end_date
          "#{start_date.strftime('%Y-%m-%d')} to #{end_date.strftime('%Y-%m-%d')}"
        else
          accounting_year.to_s
        end
      end

      # Check if this is a balance sheet report
      # @return [Boolean] true for balance sheet report codes
      def balance_sheet?
        ["14"].include?(report_code)
      end

      # Check if this is an income statement report
      # @return [Boolean] true for income statement report codes
      def income_statement?
        ["35"].include?(report_code)
      end

      # Check if this is a cash flow statement report
      # @return [Boolean] true for cash flow statement report codes
      def cash_flow_statement?
        ["18"].include?(report_code)
      end

      # Get report type category
      # @return [Symbol] Report category (:balance_sheet, :income_statement, :cash_flow, :other)
      def report_category
        return :balance_sheet if balance_sheet?
        return :income_statement if income_statement?
        return :cash_flow if cash_flow_statement?
        :other
      end
    end

    # Container for annual reports list query results.
    #
    # Provides access to all available annual reports for a company
    # with filtering and analysis capabilities.
    class AnnualReportsListing < Dry::Struct
      attribute :registry_code, Types::String.optional.default(nil)
      attribute :reports, Types::Array.of(AnnualReportListing).default([].freeze)

      # Get reports by accounting year
      # @param year [String, Integer] Accounting year to filter by
      # @return [Array<AnnualReportListing>] Reports for the specified year
      def reports_for_year(year)
        year_str = year.to_s
        reports.select { |report| report.accounting_year == year_str }
      end

      # Get unique accounting years available
      # @return [Array<String>] Sorted list of available years
      def available_years
        reports.map(&:accounting_year).compact.uniq.sort.reverse
      end

      # Get reports by type category
      # @param category [Symbol] Report category (:balance_sheet, :income_statement, :cash_flow, :other)
      # @return [Array<AnnualReportListing>] Reports in the specified category
      def reports_by_category(category)
        reports.select { |report| report.report_category == category }
      end

      # Get balance sheet reports
      # @return [Array<AnnualReportListing>] Balance sheet reports
      def balance_sheet_reports
        reports_by_category(:balance_sheet)
      end

      # Get income statement reports
      # @return [Array<AnnualReportListing>] Income statement reports
      def income_statement_reports
        reports_by_category(:income_statement)
      end

      # Get cash flow statement reports
      # @return [Array<AnnualReportListing>] Cash flow statement reports
      def cash_flow_statement_reports
        reports_by_category(:cash_flow)
      end

      # Get the most recent year with reports
      # @return [String, nil] Most recent accounting year or nil
      def latest_year
        available_years.first
      end

      # Get reports for the most recent year
      # @return [Array<AnnualReportListing>] Reports for latest year
      def latest_year_reports
        return [] unless latest_year
        reports_for_year(latest_year)
      end

      # Check if reports are available for a specific year
      # @param year [String, Integer] Accounting year to check
      # @return [Boolean] true if reports exist for the year
      def has_reports_for_year?(year)
        reports_for_year(year).any?
      end

      # Get total number of reports
      # @return [Integer] Total number of reports
      def total_reports
        reports.size
      end

      # Check if any reports are available
      # @return [Boolean] true if reports exist
      def has_reports?
        reports.any?
      end

      # Group reports by accounting year
      # @return [Hash<String, Array<AnnualReportListing>>] Reports grouped by year
      def reports_by_year
        reports.group_by(&:accounting_year)
      end

      # Get summary of available reports
      # @return [Hash] Summary with statistics and groupings
      def summary
        {
          registry_code: registry_code,
          total_reports: total_reports,
          available_years: available_years,
          latest_year: latest_year,
          reports_by_year: reports_by_year.transform_values(&:size),
          reports_by_category: {
            balance_sheet: balance_sheet_reports.size,
            income_statement: income_statement_reports.size,
            cash_flow: cash_flow_statement_reports.size,
            other: reports_by_category(:other).size
          }
        }
      end
    end

    # Represents the company requisites file download information.
    #
    # This endpoint provides a downloadable file containing company
    # requisite information (registry code, name, address, VAT number) 
    # for all companies. The file is updated once daily.
    class CompanyRequisitesFile < Dry::Struct
      attribute :creation_date, Types::String.optional.default(nil)
      attribute :total_companies, Types::Integer.default(0)
      attribute :file_name, Types::String.optional.default(nil)
      attribute :file_reference, Types::String.optional.default(nil)
      attribute :file_format, Types::String.default("xml")

      # Parse creation date to Date object
      # @return [Date, nil] Parsed creation date or nil
      def creation_date_parsed
        return nil if creation_date.nil? || creation_date.empty?
        Date.parse(creation_date.sub(/Z$/, ''))
      rescue Date::Error
        nil
      end

      # Check if file is available for download
      # @return [Boolean] true if file reference is present
      def file_available?
        !file_reference.nil? && !file_reference.empty?
      end

      # Get expected file name with creation date
      # @return [String] Expected file name with date
      def expected_file_name
        date = creation_date_parsed
        if date
          "company_requisites_#{date.strftime('%Y-%m-%d')}"
        else
          "company_requisites"
        end
      end

      # Check if file is recent (created today)
      # @return [Boolean] true if file was created today
      def recent?
        date = creation_date_parsed
        date && date == Date.today
      end

      # Get file size category based on company count
      # @return [Symbol] Size category (:small, :medium, :large, :huge)
      def size_category
        case total_companies
        when 0...10_000
          :small
        when 10_000...100_000
          :medium
        when 100_000...500_000
          :large
        else
          :huge
        end
      end

      # Get human-readable file size estimate
      # @return [String] Estimated file size description
      def estimated_size
        case size_category
        when :small
          "< 10MB"
        when :medium
          "10-100MB" 
        when :large
          "100-500MB"
        when :huge
          "> 500MB"
        end
      end

      # Get download summary information
      # @return [Hash] Summary with key download information
      def download_summary
        {
          file_name: file_name,
          expected_name: expected_file_name,
          creation_date: creation_date,
          total_companies: total_companies,
          file_format: file_format,
          file_available: file_available?,
          recent: recent?,
          size_category: size_category,
          estimated_size: estimated_size
        }
      end
    end

    # Represents a single e-invoice recipient.
    #
    # Contains information about a company's e-invoice receiving capabilities,
    # including their service provider and current status.
    class EInvoiceRecipient < Dry::Struct
      attribute :registry_code, Types::String.optional.default(nil)
      attribute :name, Types::String.optional.default(nil)
      attribute :service_provider, Types::String.optional.default(nil)
      attribute :status, Types::String.optional.default(nil)

      # Check if the recipient has a valid e-invoice relationship
      # @return [Boolean] true if status is "OK"
      def valid_recipient?
        status == "OK"
      end

      # Check if the registry code was not found or invalid
      # @return [Boolean] true if status is "MR"
      def not_found?
        status == "MR"
      end

      # Check if company name is available in the response
      # @return [Boolean] true if name is present and not empty
      def has_name?
        !name.nil? && !name.empty?
      end

      # Check if service provider information is available
      # @return [Boolean] true if service provider is present
      def has_service_provider?
        !service_provider.nil? && !service_provider.empty?
      end

      # Get status description
      # @return [String] Human-readable status description
      def status_description
        case status
        when "OK"
          "Valid e-invoice recipient"
        when "MR"
          "Registry code not found or no active relationship"
        else
          "Unknown status"
        end
      end

      # Get recipient summary
      # @return [Hash] Summary information
      def summary
        {
          registry_code: registry_code,
          name: name,
          service_provider: service_provider,
          status: status,
          status_description: status_description,
          valid_recipient: valid_recipient?,
          has_name: has_name?,
          has_service_provider: has_service_provider?
        }
      end
    end

    # Container for e-invoice recipients query results.
    #
    # Provides access to e-invoice recipient information with
    # pagination and filtering capabilities.
    class EInvoiceRecipients < Dry::Struct
      attribute :total_pages, Types::Integer.default(1)
      attribute :current_page, Types::Integer.default(1)
      attribute :recipients, Types::Array.of(EInvoiceRecipient).default([].freeze)
      attribute :return_names, Types::Bool.default(false)

      # Get valid e-invoice recipients
      # @return [Array<EInvoiceRecipient>] Recipients with status "OK"
      def valid_recipients
        recipients.select(&:valid_recipient?)
      end

      # Get recipients that were not found
      # @return [Array<EInvoiceRecipient>] Recipients with status "MR"
      def not_found_recipients
        recipients.select(&:not_found?)
      end

      # Get recipients with service provider information
      # @return [Array<EInvoiceRecipient>] Recipients that have service provider data
      def recipients_with_service_provider
        recipients.select(&:has_service_provider?)
      end

      # Group recipients by status
      # @return [Hash<String, Array<EInvoiceRecipient>>] Recipients grouped by status
      def by_status
        recipients.group_by(&:status)
      end

      # Group recipients by service provider
      # @return [Hash<String, Array<EInvoiceRecipient>>] Recipients grouped by service provider
      def by_service_provider
        recipients_with_service_provider.group_by(&:service_provider)
      end

      # Check if there are more pages available
      # @return [Boolean] true if more pages exist
      def has_more_pages?
        current_page < total_pages
      end

      # Get next page number
      # @return [Integer, nil] Next page number or nil if on last page
      def next_page
        has_more_pages? ? current_page + 1 : nil
      end

      # Get previous page number
      # @return [Integer, nil] Previous page number or nil if on first page
      def previous_page
        current_page > 1 ? current_page - 1 : nil
      end

      # Check if this is the first page
      # @return [Boolean] true if on page 1
      def first_page?
        current_page == 1
      end

      # Check if this is the last page
      # @return [Boolean] true if on the last page
      def last_page?
        current_page >= total_pages
      end

      # Get total number of recipients
      # @return [Integer] Total number of recipients
      def total_recipients
        recipients.size
      end

      # Get summary statistics
      # @return [Hash] Summary with counts and statistics
      def summary
        {
          total_recipients: total_recipients,
          valid_recipients: valid_recipients.size,
          not_found_recipients: not_found_recipients.size,
          recipients_with_service_provider: recipients_with_service_provider.size,
          return_names: return_names,
          pagination: {
            current_page: current_page,
            total_pages: total_pages,
            has_more_pages: has_more_pages?,
            next_page: next_page,
            previous_page: previous_page,
            first_page: first_page?,
            last_page: last_page?
          },
          service_providers: by_service_provider.keys,
          status_breakdown: by_status.transform_values(&:size)
        }
      end

      # Find recipient by registry code
      # @param registry_code [String] Registry code to find
      # @return [EInvoiceRecipient, nil] Found recipient or nil
      def find_recipient(registry_code)
        recipients.find { |r| r.registry_code == registry_code }
      end

      # Check if a registry code can receive e-invoices
      # @param registry_code [String] Registry code to check
      # @return [Boolean] true if the company can receive e-invoices
      def can_receive_einvoices?(registry_code)
        recipient = find_recipient(registry_code)
        recipient&.valid_recipient? || false
      end
    end

    # Container for entries and rulings query results.
    #
    # Provides access to all companies with entries or rulings
    # within a specific time period, with filtering capabilities.
    class EntriesAndRulings < Dry::Struct
      attribute :request_type, Types::String.optional.default(nil)
      attribute :start_time, Types::String.optional.default(nil)
      attribute :end_time, Types::String.optional.default(nil)
      attribute :language, Types::String.optional.default(nil)
      attribute :companies, Types::Array.of(CompanyWithEntriesRulings).default([].freeze)
      attribute :page, Types::Integer.default(1)

      # Check if this was a entries request
      # @return [Boolean] True if request type was 'K'
      def entries_request?
        request_type == "K"
      end

      # Check if this was a rulings request
      # @return [Boolean] True if request type was 'M'
      def rulings_request?
        request_type == "M"
      end

      # Get companies with enforced rulings
      # @return [Array<CompanyWithEntriesRulings>] Companies with enforced rulings
      def companies_with_enforced_rulings
        companies.select(&:has_enforced_rulings?)
      end

      # Get companies with pending rulings
      # @return [Array<CompanyWithEntriesRulings>] Companies with pending rulings
      def companies_with_pending_rulings
        companies.select(&:has_pending_rulings?)
      end

      # Get companies by legal form
      # @param legal_form [String] Legal form code (e.g., "OÜ", "AS")
      # @return [Array<CompanyWithEntriesRulings>] Filtered companies
      def companies_by_legal_form(legal_form)
        companies.select { |c| c.legal_form == legal_form }
      end

      # Get registered companies
      # @return [Array<CompanyWithEntriesRulings>] Currently registered companies
      def registered_companies
        companies.select(&:registered?)
      end

      # Find company by registry code
      # @param registry_code [String] Company registry code
      # @return [CompanyWithEntriesRulings, nil] Found company or nil
      def find_company(registry_code)
        companies.find { |c| c.registry_code == registry_code }
      end

      # Get all entries across all companies
      # @return [Array<Entry>] All entries
      def all_entries
        companies.flat_map(&:entries)
      end

      # Get all rulings across all companies
      # @return [Array<Ruling>] All rulings
      def all_rulings
        companies.flat_map(&:rulings)
      end

      # Parse start time to Time object
      # @return [Time, nil] Parsed start time or nil
      def start_time_parsed
        return nil if start_time.nil? || start_time.empty?
        Time.parse(start_time)
      rescue ArgumentError
        nil
      end

      # Parse end time to Time object
      # @return [Time, nil] Parsed end time or nil
      def end_time_parsed
        return nil if end_time.nil? || end_time.empty?
        Time.parse(end_time)
      rescue ArgumentError
        nil
      end

      # Get query duration in hours
      # @return [Float, nil] Duration in hours or nil
      def query_duration_hours
        start_t = start_time_parsed
        end_t = end_time_parsed
        
        return nil unless start_t && end_t
        
        (end_t - start_t) / 3600.0  # Convert seconds to hours
      end

      # Generate comprehensive summary statistics
      # @return [Hash] Complete summary with all statistics
      def summary
        all_entries_list = all_entries
        all_rulings_list = all_rulings
        
        {
          request_type: request_type,
          request_type_text: entries_request? ? "Entries" : "Rulings",
          time_period: {
            start: start_time,
            end: end_time,
            duration_hours: query_duration_hours&.round(2)
          },
          total_companies: companies.size,
          registered_companies: registered_companies.size,
          total_entries: all_entries_list.size,
          total_rulings: all_rulings_list.size,
          enforced_rulings: all_rulings_list.count(&:enforced?),
          pending_rulings: all_rulings_list.count { |r| !r.enforced? },
          companies_with_enforced_rulings: companies_with_enforced_rulings.size,
          companies_with_pending_rulings: companies_with_pending_rulings.size,
          entries_by_category: all_entries_list.group_by(&:entry_category).transform_values(&:size),
          rulings_by_category: all_rulings_list.group_by(&:ruling_category).transform_values(&:size),
          legal_forms: companies.group_by(&:legal_form).transform_values(&:size),
          page: page,
          language: language
        }
      end
    end

    class RevenueByEMTAK < Dry::Struct
      attribute :emtak_code, Types::String.optional.default(nil)
      attribute :emtak_version, Types::String.optional.default(nil)
      attribute :amount, Types::Float.optional.default(nil)
      attribute :percentage, Types::Float.optional.default(nil)
      attribute :coefficient, Types::Float.optional.default(nil)
      attribute :is_main_activity, Types::Bool.optional.default(nil)
    end

    class RevenueBreakdownEntry < Dry::Struct
      attribute :registry_code, Types::String.optional.default(nil)
      attribute :legal_form, Types::String.optional.default(nil)
      attribute :submission_time, Types::String.optional.default(nil)
      attribute :accounting_year, Types::String.optional.default(nil)
      attribute :operating_without_revenue, Types::Bool.optional.default(nil)
      attribute :revenues, Types::Array.of(RevenueByEMTAK).optional.default([].freeze)
    end

    class RevenueBreakdown < Dry::Struct
      attribute :entries, Types::Array.of(RevenueBreakdownEntry).optional.default([].freeze)
      attribute :total_count, Types::Integer.optional.default(nil)
      attribute :page, Types::Integer.optional.default(nil)
    end
  end
end