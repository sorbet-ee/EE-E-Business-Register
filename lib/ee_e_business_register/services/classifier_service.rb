# frozen_string_literal: true

module EeEBusinessRegister
  module Services
    # Service for retrieving Estonian e-Business Register classifier/reference data
    #
    # Classifiers are reference data sets that define valid values for various
    # fields in the Estonian Business Register. This includes legal forms (OÜ, AS, etc.),
    # company statuses, person roles, regions, countries, and other standardized
    # code lists used throughout the Estonian business registration system.
    #
    # The service provides access to both individual classifiers and complete
    # classifier datasets, with automatic language support and proper model parsing.
    #
    # @example Get legal forms
    #   service = ClassifierService.new(client)
    #   forms = service.get_classifier(:legal_forms)
    #   forms.values.each { |form| puts "#{form.code}: #{form.name}" }
    #
    class ClassifierService
      # Mapping of human-readable classifier names to Estonian API classifier codes
      #
      # This constant defines all available classifier types and their corresponding
      # internal codes used by the Estonian e-Business Register API. Each classifier
      # contains a set of valid codes and descriptions for a specific business domain.
      #
      AVAILABLE_CLASSIFIERS = {
        company_subtypes: "ALALIIGID",        # Detailed company type classifications
        representation_types: "ESINDTYYBID",  # Types of company representation
        status_changes: "EVSTAATMUUT",        # Company status change types
        company_statuses: "EVSTAATUSED",      # Company registration statuses (Active, Deleted, etc.)
        person_roles: "ISIKROLLID",           # Roles people can have in companies
        report_types: "MAJARULIIGID",         # Annual report type classifications
        legal_forms: "OIGVORMID",             # Company legal structures (OÜ, AS, MTÜ, etc.)
        pledge_statuses: "PANDIOLEKUD",       # Asset pledge/mortgage statuses
        regions: "REGPIIRK",                  # Estonian administrative regions
        countries: "RIIGID",                  # Country codes and names
        communication_types: "SIDEVAH",       # Communication method types
        dissolution_sections: "SUNDLALAJAOT", # Legal dissolution section classifications
        dissolution_reasons: "SUNDLALUSED",   # Reasons for company dissolution
        currencies: "VALUUTAD"                # Supported currency codes
      }.freeze

      # Initialize the service with a SOAP client
      #
      # @param client [Client] SOAP client instance for API communication
      #
      def initialize(client = Client.new)
        @client = client
      end

      # Get a specific classifier by type or code
      #
      # Retrieves a single classifier dataset from the Estonian e-Business Register.
      # The classifier contains all valid codes and descriptions for a specific
      # business domain (e.g., legal forms, company statuses, regions).
      #
      # @param type [Symbol, String] Classifier type (from AVAILABLE_CLASSIFIERS) or raw Estonian code
      # @return [Models::Classifier] Classifier object with code/name pairs
      # @raise [ArgumentError] If classifier type is unknown
      # @raise [APIError] If API error occurs
      #
      # @example Get legal forms
      #   legal_forms = service.get_classifier(:legal_forms)
      #   legal_forms.values.each { |form| puts "#{form.code}: #{form.name}" }
      #
      # @example Get company statuses  
      #   statuses = service.get_classifier(:company_statuses)
      #   active_status = statuses.values.find { |s| s.code == 'R' }
      #
      def get_classifier(type)
        # Convert friendly name to Estonian API classifier code
        classifier_code = resolve_classifier_code(type)
        
        # Request specific classifier in configured language
        response = @client.call(:klassifikaatorid_v1, {
          klassifikaator: classifier_code,
          keel: EeEBusinessRegister.configuration.language
        })
        
        # Parse response and return Classifier model
        parse_classifier_response(response.body.dig(:klassifikaatorid_v1_response, :keha))
      end

      # Get all available classifiers in one request
      #
      # Retrieves the complete set of all classifier datasets from the Estonian
      # e-Business Register. This is useful for applications that need to cache
      # all reference data locally or display comprehensive lookup tables.
      #
      # @return [Array<Models::Classifier>] Array of all classifier objects
      # @raise [APIError] If API error occurs
      #
      # @example Get all classifiers
      #   all_classifiers = service.get_all_classifiers
      #   all_classifiers.each do |classifier|
      #     puts "#{classifier.name}: #{classifier.values.size} values"
      #   end
      #
      def get_all_classifiers
        # Request all classifiers without specifying a particular one
        response = @client.call(:klassifikaatorid_v1, {
          keel: EeEBusinessRegister.configuration.language
        })
        
        # Parse response and return array of Classifier models
        parse_classifiers_response(response.body.dig(:klassifikaatorid_v1_response, :keha))
      end

      # Get list of all available classifier type names
      #
      # Returns a list of all classifier types that can be used with the
      # get_classifier method. These are the human-readable names mapped
      # to Estonian API classifier codes.
      #
      # @return [Array<Symbol>] Array of available classifier type symbols
      #
      # @example List available classifier types
      #   types = service.available_classifiers
      #   puts types  # => [:company_subtypes, :legal_forms, :company_statuses, ...]
      #
      def available_classifiers
        AVAILABLE_CLASSIFIERS.keys
      end

      private

      def resolve_classifier_code(type)
        if type.is_a?(Symbol)
          AVAILABLE_CLASSIFIERS[type] || raise(ArgumentError, "Unknown classifier type: #{type}")
        else
          type.to_s.upcase
        end
      end

      def parse_classifier_response(response)
        return nil unless response && response[:klassifikaator]
        
        build_classifier(response[:klassifikaator])
      end

      def parse_classifiers_response(response)
        return [] unless response && response[:klassifikaator]
        
        classifiers = response[:klassifikaator]
        classifiers = [classifiers] unless classifiers.is_a?(Array)
        
        classifiers.map { |data| build_classifier(data) }
      end

      def build_classifier(data)
        Models::Classifier.new(
          code: data[:klassifikaatori_kood],
          name: data[:klassifikaatori_nimetus],
          values: build_classifier_values(data[:klassifikaatori_vaartused])
        )
      end

      def build_classifier_values(values_data)
        return [] unless values_data && values_data[:klassifikaatori_vaartus]
        
        values = values_data[:klassifikaatori_vaartus]
        values = [values] unless values.is_a?(Array)
        
        values.map do |value|
          Models::ClassifierValue.new(
            code: value[:klassifikaatori_vaartuse_kood],
            name: value[:klassifikaatori_vaartuse_nimetus],
            valid_from: value[:klassifikaatori_vaartuse_algus_kpv]&.strftime('%Y-%m-%d'),
            valid_to: value[:klassifikaatori_vaartuse_lopp_kpv]&.strftime('%Y-%m-%d')
          )
        end
      end
    end
  end
end