# frozen_string_literal: true

require_relative "lib/ee_e_business_register/version"

Gem::Specification.new do |spec|
  spec.name = "ee_e_business_register"
  spec.version = EeEBusinessRegister::VERSION
  spec.authors = ["Angelos Kapsimanis"]
  spec.email = ["contact@angeloskapsimanis.com"]

  spec.summary = "A clean, professional Ruby client for accessing Estonian company data from the e-Business Register"
  spec.description = "Ruby gem providing a clean, professional interface to the Estonian e-Business Register API. Allows searching for companies, retrieving detailed company information, annual reports, and more."
  spec.homepage = "https://github.com/angeloskapsimanis/ee_e_business_register"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/angeloskapsimanis/ee_e_business_register"
  spec.metadata["changelog_uri"] = "https://github.com/angeloskapsimanis/ee_e_business_register/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["lib/**/*.rb"] + Dir["*.md"] + ["LICENSE.txt"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "savon", "~> 2.14"
  spec.add_dependency "activesupport", ">= 7.0", "< 9.0"
  spec.add_dependency "dry-types", "~> 1.7"
  spec.add_dependency "dry-struct", "~> 1.6"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end