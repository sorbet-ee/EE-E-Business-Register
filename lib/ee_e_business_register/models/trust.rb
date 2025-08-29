# frozen_string_literal: true

require 'dry-struct'
require_relative '../types'

module EeEBusinessRegister
  module Models
    class TrustPerson < Dry::Struct
      attribute :role, Types::String.optional.default(nil)
      attribute :first_name, Types::String.optional.default(nil)
      attribute :last_name, Types::String.optional.default(nil)
      attribute :company_name, Types::String.optional.default(nil)
      attribute :id_code, Types::String.optional.default(nil)
      attribute :foreign_id_code, Types::String.optional.default(nil)
      attribute :foreign_id_country, Types::String.optional.default(nil)
      attribute :foreign_id_country_text, Types::String.optional.default(nil)
      attribute :birth_date, Types::String.optional.default(nil)
      attribute :address_country, Types::String.optional.default(nil)
      attribute :address_country_text, Types::String.optional.default(nil)
      attribute :residence_country, Types::String.optional.default(nil)
      attribute :residence_country_text, Types::String.optional.default(nil)
      attribute :start_date, Types::String.optional.default(nil)
      attribute :end_date, Types::String.optional.default(nil)
      attribute :discrepancy_notice_submitted, Types::Bool.optional.default(nil)
    end

    class Trust < Dry::Struct
      attribute :trust_id, Types::String.optional.default(nil)
      attribute :name, Types::String.optional.default(nil)
      attribute :registration_date, Types::String.optional.default(nil)
      attribute :status, Types::String.optional.default(nil)
      attribute :country, Types::String.optional.default(nil)
      attribute :country_text, Types::String.optional.default(nil)
      attribute :total_beneficial_owners, Types::Integer.optional.default(nil)
      attribute :hidden_beneficial_owners, Types::Integer.optional.default(nil)
      attribute :absence_notice, Types::Bool.optional.default(nil)
      attribute :persons, Types::Array.of(TrustPerson).optional.default([].freeze)
    end

    class Trusts < Dry::Struct
      attribute :items, Types::Array.of(Trust).optional.default([].freeze)
      attribute :total_count, Types::Integer.optional.default(nil)
      attribute :page, Types::Integer.optional.default(nil)
      attribute :per_page, Types::Integer.optional.default(nil)
    end
  end
end