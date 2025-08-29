# frozen_string_literal: true

module EeEBusinessRegister
  module Services
    class TrustsService
      def initialize(client = Client.new)
        @client = client
        @credentials = EeEBusinessRegister.configuration.credentials
      end

      def search_trusts(trust_name: nil, person_first_name: nil, person_last_name: nil, 
                       person_birth_date: nil, person_id_code: nil, only_valid: false,
                       page: 1, per_page: 10)
        
        params = build_trusts_params(
          trust_name: trust_name,
          person_first_name: person_first_name,
          person_last_name: person_last_name,
          person_birth_date: person_birth_date,
          person_id_code: person_id_code,
          only_valid: only_valid,
          page: page,
          per_page: per_page
        )
        
        response = @client.call(:usaldushaldused_v1, params)
        parse_trusts_response(response)
      end

      def get_trust_by_name(trust_name, only_valid: true)
        search_trusts(trust_name: trust_name, only_valid: only_valid)
      end

      def get_trusts_by_person(person_id_code: nil, person_first_name: nil, 
                              person_last_name: nil, person_birth_date: nil,
                              only_valid: true)
        search_trusts(
          person_id_code: person_id_code,
          person_first_name: person_first_name,
          person_last_name: person_last_name,
          person_birth_date: person_birth_date,
          only_valid: only_valid
        )
      end

      private

      def build_trusts_params(trust_name: nil, person_first_name: nil, person_last_name: nil,
                             person_birth_date: nil, person_id_code: nil, only_valid: false,
                             page: 1, per_page: 10)
        {
          ariregister_kasutajanimi: @credentials[:username],
          ariregister_parool: @credentials[:password],
          ariregister_sessioon: @credentials[:session],
          ariregister_valjundi_formaat: 'xml',
          usaldushalduse_nimi: trust_name,
          fyysilise_isiku_eesnimi: person_first_name,
          fyysilise_isiku_perekonnanimi: person_last_name,
          fyysilise_isiku_synniaeg: person_birth_date,
          fyysilise_isiku_kood: person_id_code,
          ainult_kehtivad: only_valid,
          keel: EeEBusinessRegister.configuration.language,
          evarv: per_page,
          lehekylg: page
        }.compact
      end

      def parse_trusts_response(response)
        return nil unless response && response[:keha]
        
        body = response[:keha]
        
        Models::Trusts.new(
          items: parse_trust_items(body[:usaldushaldused]),
          total_count: body[:leitud_arv],
          page: response.dig(:paring, :lehekylg) || 1,
          per_page: response.dig(:paring, :evarv) || 10
        )
      end

      def parse_trust_items(trusts_data)
        return [] unless trusts_data && trusts_data[:item]
        
        items = trusts_data[:item]
        items = [items] unless items.is_a?(Array)
        
        items.map { |trust| build_trust(trust) }
      end

      def build_trust(trust_data)
        Models::Trust.new(
          trust_id: trust_data[:usaldushalduse_id],
          name: trust_data[:nimi],
          registration_date: trust_data[:registreerimise_kpv],
          status: trust_data[:staatus],
          country: trust_data[:riik],
          country_text: trust_data[:riik_tekstina],
          total_beneficial_owners: trust_data[:kasusaajate_arv_kokku],
          hidden_beneficial_owners: trust_data[:peidetud_kasusaajate_arv],
          absence_notice: trust_data[:lahknevusteade_puudumisest],
          persons: build_trust_persons(trust_data[:isikud])
        )
      end

      def build_trust_persons(persons_data)
        return [] unless persons_data && persons_data[:isik]
        
        persons = persons_data[:isik]
        persons = [persons] unless persons.is_a?(Array)
        
        persons.map { |person| build_trust_person(person) }
      end

      def build_trust_person(person_data)
        Models::TrustPerson.new(
          role: person_data[:roll],
          first_name: person_data[:eesnimi],
          last_name: person_data[:nimi],
          company_name: (!person_data[:eesnimi] && person_data[:nimi]) ? person_data[:nimi] : nil,
          id_code: person_data[:isikukood],
          foreign_id_code: person_data[:valis_kood],
          foreign_id_country: person_data[:valis_kood_riik],
          foreign_id_country_text: person_data[:valis_kood_riik_tekstina],
          birth_date: person_data[:synniaeg],
          address_country: person_data[:aadress_riik],
          address_country_text: person_data[:aadress_riik_tesktina] || person_data[:aadress_riik_tekstina],
          residence_country: person_data[:elukoht_riik],
          residence_country_text: person_data[:elukoht_riik_tekstina],
          start_date: person_data[:algus_kpv],
          end_date: person_data[:lopp_kpv],
          discrepancy_notice_submitted: person_data[:lahknevusteade_esitatud]
        )
      end
    end
  end
end