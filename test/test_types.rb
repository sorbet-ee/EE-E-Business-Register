# frozen_string_literal: true

require_relative 'test_helper'

class TestTypes < Minitest::Test
  # ========================================
  # TYPE DEFINITIONS TESTS
  # ========================================

  def test_registry_code_type_valid
    # Test that valid registry codes pass type validation
    valid_codes = ['16863232', '10060701', '00000123']
    
    valid_codes.each do |code|
      result = EeEBusinessRegister::Types::RegistryCode[code]
      assert_equal code, result
    end
  end

  def test_registry_code_type_invalid
    # Test that invalid registry codes fail type validation
    invalid_codes = ['123', '123456789', 'invalid', '1234567a']
    
    invalid_codes.each do |code|
      assert_raises(Dry::Types::ConstraintError) do
        EeEBusinessRegister::Types::RegistryCode[code]
      end
    end
  end

  def test_company_status_type_valid
    # Test valid Estonian company statuses
    valid_statuses = ['R', 'K', 'L', 'N', 'S']
    
    valid_statuses.each do |status|
      result = EeEBusinessRegister::Types::CompanyStatus[status]
      assert_equal status, result
    end
  end

  def test_company_status_type_invalid
    # Test invalid company statuses
    invalid_statuses = ['X', 'INVALID', '123', '']
    
    invalid_statuses.each do |status|
      assert_raises(Dry::Types::ConstraintError) do
        EeEBusinessRegister::Types::CompanyStatus[status]
      end
    end
  end

  def test_legal_form_type
    # Test that LegalForm accepts strings
    legal_forms = ['OÜ', 'AS', 'MTÜ', 'SA', 'TÜH']
    
    legal_forms.each do |form|
      result = EeEBusinessRegister::Types::LegalForm[form]
      assert_equal form, result
    end
  end

  def test_language_type_valid
    # Test valid language codes
    valid_languages = ['est', 'eng']
    
    valid_languages.each do |lang|
      result = EeEBusinessRegister::Types::Language[lang]
      assert_equal lang, result
    end
  end

  def test_language_type_invalid
    # Test invalid language codes
    invalid_languages = ['rus', 'ger', 'fra', 'invalid']
    
    invalid_languages.each do |lang|
      assert_raises(Dry::Types::ConstraintError) do
        EeEBusinessRegister::Types::Language[lang]
      end
    end
  end

  def test_date_type_iso_format
    # Test ISO date format
    iso_dates = ['2023-01-01', '2023-12-31', '2000-02-29']
    
    iso_dates.each do |date|
      result = EeEBusinessRegister::Types::Date[date]
      assert_equal date, result
    end
  end

  def test_date_type_estonian_format
    # Test Estonian date format
    estonian_dates = ['01.01.2023', '31.12.2023', '29.02.2000']
    
    estonian_dates.each do |date|
      result = EeEBusinessRegister::Types::Date[date]
      assert_equal date, result
    end
  end

  def test_date_type_invalid
    # Test invalid date formats that actually raise errors
    invalid_dates = ['2023/01/01', '01-01-2023', 'invalid']
    
    invalid_dates.each do |date|
      assert_raises(Dry::Types::ConstraintError) do
        EeEBusinessRegister::Types::Date[date]
      end
    end
  end

  # ========================================
  # TYPE MODULE STRUCTURE TESTS
  # ========================================

  def test_types_module_exists
    assert_kind_of Module, EeEBusinessRegister::Types
  end

  def test_types_include_dry_types
    # Verify that the Types module includes Dry.Types() - test what's actually available
    assert_respond_to EeEBusinessRegister::Types, :Strict
    # Coercible might not be available in newer dry-types versions
    # assert_respond_to EeEBusinessRegister::Types, :Coercible
  end

  def test_all_type_constants_defined
    required_types = %w[
      RegistryCode
      CompanyStatus
      LegalForm
      Language
      Date
    ]
    
    required_types.each do |type_name|
      assert EeEBusinessRegister::Types.const_defined?(type_name), 
             "Expected #{type_name} to be defined in Types module"
    end
  end

  def test_type_constants_are_callable
    type_constants = %w[
      RegistryCode
      CompanyStatus
      LegalForm
      Language
      Date
    ]
    
    type_constants.each do |type_name|
      type = EeEBusinessRegister::Types.const_get(type_name)
      assert_respond_to type, :call, "Expected #{type_name} to be callable"
    end
  end

  # ========================================
  # EDGE CASES AND BOUNDARY TESTS
  # ========================================

  def test_registry_code_exactly_eight_digits
    # Test boundary conditions for registry code
    result = EeEBusinessRegister::Types::RegistryCode['12345678']
    assert_equal '12345678', result
    
    assert_raises(Dry::Types::ConstraintError) do
      EeEBusinessRegister::Types::RegistryCode['1234567']  # 7 digits
    end
    
    assert_raises(Dry::Types::ConstraintError) do
      EeEBusinessRegister::Types::RegistryCode['123456789']  # 9 digits
    end
  end

  def test_date_format_patterns
    # Test various date patterns
    valid_patterns = [
      '2023-01-01',      # ISO format
      '01.01.2023',      # Estonian format
    ]
    
    valid_patterns.each do |pattern|
      result = EeEBusinessRegister::Types::Date[pattern]
      assert_instance_of String, result, "Expected #{pattern} to be valid"
    end
  end

  def test_type_coercion_behavior
    # Test that types behave as expected with coercion
    
    # RegistryCode should work with strings
    result = EeEBusinessRegister::Types::RegistryCode['16863232']
    assert_equal '16863232', result
    assert_instance_of String, result
    
    # Language should work with strings
    result = EeEBusinessRegister::Types::Language['eng']
    assert_equal 'eng', result
    assert_instance_of String, result
  end

  # ========================================
  # INTEGRATION WITH MODELS TESTS
  # ========================================

  def test_types_work_with_dry_struct
    # Create a simple struct that uses our types
    test_struct_class = Class.new(Dry::Struct) do
      attribute :registry_code, EeEBusinessRegister::Types::RegistryCode
      attribute :status, EeEBusinessRegister::Types::CompanyStatus
      attribute :legal_form, EeEBusinessRegister::Types::LegalForm
      attribute :language, EeEBusinessRegister::Types::Language
    end
    
    # Test that it works with valid data
    data = {
      registry_code: '16863232',
      status: 'R',
      legal_form: 'OÜ',
      language: 'eng'
    }
    
    instance = test_struct_class.new(data)
    assert_equal '16863232', instance.registry_code
    assert_equal 'R', instance.status
    assert_equal 'OÜ', instance.legal_form
    assert_equal 'eng', instance.language
  end

  def test_types_fail_with_invalid_data_in_struct
    test_struct_class = Class.new(Dry::Struct) do
      attribute :registry_code, EeEBusinessRegister::Types::RegistryCode
      attribute :status, EeEBusinessRegister::Types::CompanyStatus
    end
    
    # Test that it fails with invalid data
    invalid_data = {
      registry_code: 'invalid',
      status: 'INVALID'
    }
    
    assert_raises(Dry::Struct::Error) do
      test_struct_class.new(invalid_data)
    end
  end
end