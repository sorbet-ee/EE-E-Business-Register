# frozen_string_literal: true

module EeEBusinessRegister
  module Services
    # Service class for all Estonian e-Business Register company-related operations
    #
    # This service provides a high-level interface to interact with company data
    # from the Estonian e-Business Register API. It handles SOAP request/response
    # processing, data parsing, and model object creation.
    #
    # The service includes methods for:
    # - Finding companies by registry code
    # - Retrieving detailed company information
    # - Accessing company documents and annual reports
    # - Getting representation rights and person changes
    # - Getting beneficial owners information
    #
    # All methods include proper validation, error handling, and return
    # structured model objects for easy consumption by client code.
    #
    # @example Basic usage
    #   client = Client.new(config)
    #   service = CompanyService.new(client)
    #   company = service.find_by_registry_code('16863232')
    #
    class CompanyService
      # Initialize the service with a SOAP client
      #
      # @param client [Client] SOAP client instance for API communication
      #
      def initialize(client = Client.new)
        @client = client
      end

      # Find a company by its 8-digit Estonian registry code
      #
      # This method retrieves basic company information including name, status,
      # legal form, registration dates, address, and contact information.
      # Uses the Estonian API's 'lihtandmed_v2' operation.
      #
      # @param code [String, Integer] 8-digit Estonian company registry code
      # @return [Models::Company] Company model with basic information
      # @raise [ArgumentError] If registry code format is invalid
      # @raise [APIError] If company not found or API error occurs
      #
      # @example
      #   company = service.find_by_registry_code('16863232')
      #   puts company.name  # => "Sorbeet Payments OÜ"
      #   puts company.active?  # => true
      #
      def find_by_registry_code(code)
        code = code.to_s.strip
        validate_registry_code(code)
        
        # Call Estonian API for basic company data
        response = @client.call(:lihtandmed_v2, {
          ariregistri_kood: code
        })
        
        # Parse response and create Company model object
        parse_company(response.body.dig(:lihtandmed_v2_response, :keha, :ettevotjad, :item))
      rescue => e
        handle_error(e, "finding company", code)
      end

      # Search for companies by name using partial matching
      #
      # @deprecated This method is no longer functional as the Estonian e-Business Register
      #   has removed the 'nimeparing_v1' operation from their API. This method will always
      #   raise an APIError when called.
      #
      # Originally this method performed fuzzy search across Estonian company names,
      # supporting partial matches and returning multiple results.
      #
      # @param name [String] Company name or partial name to search for
      # @param max_results [Integer] Maximum number of results (1-100, default: 10)
      # @return [Array<Models::Company>] This method will raise an error
      # @raise [APIError] Always raised - functionality no longer available
      #
      # @example This will raise an APIError:
      #   # results = service.search_by_name('Swedbank', 5)
      #   
      #   # Use find_by_registry_code instead:
      #   company = service.find_by_registry_code('10060701')
      #
      def search_by_name(name, max_results = 10)
        raise ArgumentError, "Name is required" if name.nil? || name.empty?
        raise ArgumentError, "Max results must be between 1 and 100" unless (1..100).include?(max_results)
        
        # CURRENT LIMITATION: The nimeparing_v1 operation is not available in the current API
        # The Estonian e-Business Register API has removed the company name search functionality
        # For now, we return an informative error message
        raise APIError, "Company name search is currently not available. The Estonian e-Business Register has removed the 'nimeparing_v1' operation from their API. Please use the 'find by registry code' functionality instead, or contact the Estonian Business Register for alternative search methods."
        
        # Alternative implementation could use ettevotja_rekvisiidid_v2 if we had the specific parameters
        # But that would require either company name exact match or registry code
        
      rescue => e
        handle_error(e, "searching companies", name)
      end

      # Get comprehensive detailed data for a company
      #
      # Retrieves extensive company information including general data,
      # personnel information, detailed addresses, and other comprehensive
      # company details. Uses the Estonian API's 'detailandmed_v2' operation.
      #
      # @param code [String, Integer] 8-digit Estonian company registry code
      # @return [Hash] Raw detailed company data from Estonian API
      # @raise [ArgumentError] If registry code format is invalid
      # @raise [APIError] If company not found or API error occurs
      #
      # @example
      #   details = service.get_detailed_data('16863232')
      #   puts details[:general_data][:email]
      #   puts details[:personnel][:board_members]
      #
      def get_detailed_data(code)
        code = code.to_s.strip
        validate_registry_code(code)
        
        # TEMPORARY WORKAROUND: Use lihtandmed_v2 instead of detailandmed_v2
        # The detailandmed operations have a complex parameter structure issue
        # that needs further investigation with the Estonian API documentation
        response = @client.call(:lihtandmed_v2, {
          ariregistri_kood: code
        })
        
        # Parse the response and return structured data
        data = response.body.dig(:lihtandmed_v2_response, :keha, :ettevotjad, :item)
        
        if data
          # Convert to a more detailed structure
          {
            general_data: {
              registry_code: data[:ariregistri_kood],
              name: data[:evnimi],
              status: data[:staatus],
              status_text: data[:staatus_tekstina],
              legal_form: data[:oiguslik_vorm],
              legal_form_text: data[:oiguslik_vorm_tekstina],
              email: data[:email],
              capital: data[:kapital],
              registration_date: data[:registreerimise_kpv],
              address: data[:evaadressid]
            },
            # Personnel data would come from detailandmed_v2 when fixed
            personnel_data: {
              note: "Personnel data requires detailandmed_v2 operation which has a known issue"
            }
          }
        else
          nil
        end
      rescue => e
        handle_error(e, "getting detailed data", code)
      end

      # Get list of documents filed by a company
      #
      # Retrieves all documents that have been filed with the Estonian
      # Business Register for the specified company. This includes articles
      # of incorporation, amendments, annual reports, and other official filings.
      # Uses the Estonian API's 'ettevotja_dokumentide_loetelu_v1' operation.
      #
      # @param code [String, Integer] 8-digit Estonian company registry code
      # @return [Array<Hash>] Array of document information hashes
      # @raise [ArgumentError] If registry code format is invalid
      # @raise [APIError] If company not found or API error occurs
      #
      # @example
      #   docs = service.get_documents('16863232')
      #   docs.each { |doc| puts "#{doc[:type]}: #{doc[:name]}" }
      #
      def get_documents(code)
        code = code.to_s.strip
        validate_registry_code(code)
        
        # Request all documents for the company using the correct operation name
        response = @client.call(:ettevotja_dokumentide_loetelu_v1, {
          ariregistri_kood: code
        })
        
        # Parse and return array of document information
        parse_documents(response.body.dig(:ettevotja_dokumentide_loetelu_v1_response, :keha))
      rescue => e
        handle_error(e, "getting documents", code)
      end

      # Get annual reports list
      def get_annual_reports(code)
        code = code.to_s.strip
        validate_registry_code(code)
        
        response = @client.call(:majandusaasta_aruannete_loetelu_v1, {
          ariregistri_kood: code
        })
        
        parse_annual_reports(response.body.dig(:majandusaasta_aruannete_loetelu_v1_response, :keha))
      rescue => e
        handle_error(e, "getting annual reports", code)
      end

      # Get specific annual report
      def get_annual_report(code, year:, report_type: 'balance_sheet')
        code = code.to_s.strip
        validate_registry_code(code)
        
        response = @client.call(:majandusaasta_aruande_kirjed_v1, {
          ariregistri_kood: code,
          aruande_liik: map_report_type(report_type),
          majandusaasta_aasta: year.to_i
        })
        
        parse_annual_report(response.body.dig(:majandusaasta_aruande_kirjed_v1_response, :paring))
      rescue => e
        handle_error(e, "getting annual report", code)
      end

      # Get representation rights
      def get_representation(code)
        code = code.to_s.strip
        validate_registry_code(code)
        
        response = @client.call(:esindus_v2, {
          ariregistri_kood: code
        })
        
        parse_representation(response.body.dig(:esindus_v2_response, :keha))
      rescue => e
        handle_error(e, "getting representation", code)
      end

      # Get person changes
      def get_person_changes(code, from_date: nil, to_date: nil)
        code = code.to_s.strip
        validate_registry_code(code)
        
        params = { ariregistri_kood: code }
        params[:muudatuse_kuupaev_alates] = format_date(from_date) if from_date
        params[:muudatuse_kuupaev_kuni] = format_date(to_date) if to_date
        
        response = @client.call(:isiku_muudatused_v1, params)
        
        parse_person_changes(response.body.dig(:isiku_muudatused_v1_response, :paring))
      rescue => e
        handle_error(e, "getting person changes", code)
      end

      # Get beneficial owners
      def get_beneficial_owners(code)
        code = code.to_s.strip
        validate_registry_code(code)
        
        response = @client.call(:tegelikud_kasusaajad_v2, {
          ariregistri_kood: code
        })
        
        parse_beneficial_owners(response.body.dig(:tegelikud_kasusaajad_v2_response, :keha))
      rescue => e
        handle_error(e, "getting beneficial owners", code)
      end

      private

      # Validation methods
      def validate_registry_code(code)
        unless code =~ /^\d{8}$/
          raise ArgumentError, "Invalid registry code: #{code}. Must be 8 digits."
        end
      end

      def format_date(date)
        return nil unless date
        date = Date.parse(date.to_s) if date.is_a?(String)
        date.strftime('%Y-%m-%d')
      end

      def map_report_type(type)
        case type.to_s.downcase
        when 'balance_sheet' then 'bilanss'
        when 'income_statement' then 'kasumi_aruanne'
        when 'cash_flow' then 'rahavoogude_aruanne'
        else type
        end
      end

      # Parsing methods
      def parse_company(data)
        return nil unless data
        
        Models::Company.new(
          registry_code: data[:ariregistri_kood],
          name: data[:evnimi] || "Unknown Company",  # Provide fallback for nil names
          status: data[:staatus],
          status_text: data[:staatus_tekstina],
          legal_form: data[:oiguslik_vorm],
          legal_form_text: data[:oiguslik_vorm_tekstina],
          registration_date: parse_date(data[:registreerimise_kpv]),
          deletion_date: parse_date(data[:registrist_kustutamise_aeg]),
          address: parse_address(data[:evaadressid]),  # Address data is in evaadressid
          email: data[:email],
          capital: data[:kapital]&.to_f,
          capital_currency: data[:kapital_valuuta],
          region: data[:piirkond],
          region_text: data[:piirkond_tekstina]
        )
      end

      def parse_search_results(data)
        return [] unless data
        
        items = data[:item] || []
        items = [items] unless items.is_a?(Array)
        
        items.map { |item| parse_company(item) }.compact
      end

      def parse_detailed_company(data)
        return nil unless data
        # Return raw hash for now - would need proper model
        data
      end

      def parse_documents(data)
        return [] unless data
        # The documents are under ettevotja_dokumendid key for the v1 operation
        documents_data = data[:ettevotja_dokumendid]
        return [] unless documents_data
        
        # documents_data is already an Array of document hashes
        documents_data.is_a?(Array) ? documents_data : [documents_data]
      end

      def parse_annual_reports(data)
        return [] unless data
        # Return raw array for now - would need proper model
        Array(data[:majandusaasta_aruanded])
      end

      def parse_annual_report(data)
        return nil unless data
        # Return raw hash for now - would need proper model
        data
      end

      def parse_representation(data)
        return [] unless data
        # The persons with representation rights are in ettevotjad -> item -> isikud -> item
        persons_data = data.dig(:ettevotjad, :item, :isikud, :item)
        return [] unless persons_data
        Array(persons_data)
      end

      def parse_person_changes(data)
        return [] unless data
        # Return raw array for now - would need proper model
        Array(data[:muudatus])
      end

      def parse_beneficial_owners(data)
        return [] unless data
        # Return raw array for now - would need proper model
        Array(data.dig(:kasusaajad, :kasusaaja))
      end

      def parse_address(data)
        return nil unless data
        
        Models::Address.new(
          full_address: data[:aadress_ads__ads_normaliseeritud_taisaadress],
          county: data[:asukoha_maakond_tekstina],
          city: data[:asukoha_ehak_tekstina],
          street: data[:asukoht_ettevotja_aadressis],
          postal_code: data[:indeks_ettevotja_aadressis],
          ads_oid: data[:ads_oid],
          ads_adr_id: data[:ads_adr_id]
        )
      end

      def parse_date(date_string)
        return nil unless date_string
        Date.parse(date_string)
      rescue
        nil
      end

      # Error handling
      def handle_error(error, action, context)
        if error.is_a?(APIError)
          raise error
        elsif error.message.include?("SOAP")
          raise APIError, "Failed #{action} for #{context}: #{error.message}"
        else
          raise APIError, "Unexpected error #{action} for #{context}: #{error.message}"
        end
      end
    end
  end
end