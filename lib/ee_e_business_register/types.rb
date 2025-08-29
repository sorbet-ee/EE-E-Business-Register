# frozen_string_literal: true

require "dry-types"

module EeEBusinessRegister
  module Types
    include Dry.Types()

    RegistryCode = Strict::String.constrained(format: /\A\d{8}\z/)
    
    CompanyStatus = Strict::String.enum(
      "R", # Registered
      "K", # Deleted
      "L", # Liquidated
      "N", # Active in liquidation
      "S" # Active in reorganization
    )
    
    LegalForm = Strict::String
    Language = Strict::String.enum("est", "eng")
    
    Date = Strict::String.constrained(format: /\A\d{4}-\d{2}-\d{2}\z/) | Strict::String.constrained(format: /\A\d{2}\.\d{2}\.\d{4}\z/)
  end
end