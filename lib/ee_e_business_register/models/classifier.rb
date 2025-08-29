# frozen_string_literal: true

require "dry-struct"

module EeEBusinessRegister
  module Models
    class ClassifierValue < Dry::Struct
      attribute :code, Types::String
      attribute :name, Types::String
      attribute :valid_from, Types::String.optional
      attribute :valid_to, Types::String.optional.default(nil)
    end

    class Classifier < Dry::Struct
      attribute :code, Types::String
      attribute :name, Types::String
      attribute :values, Types::Array.of(ClassifierValue)

      def find_value(code)
        values.find { |v| v.code == code }
      end

      def active_values
        values.select { |v| v.valid_to.nil? }
      end
    end
  end
end