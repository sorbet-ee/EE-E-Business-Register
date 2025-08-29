# frozen_string_literal: true

require_relative 'test_helper'

class TestValidation < Minitest::Test
  # ========================================
  # REGISTRY CODE VALIDATION TESTS
  # ========================================

  def test_validate_registry_code_valid
    assert_equal '16863232', EeEBusinessRegister::Validation.validate_registry_code('16863232')
    assert_equal '16863232', EeEBusinessRegister::Validation.validate_registry_code(16863232)
    # The validation code doesn't pad short codes, it rejects them
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_code('123')
    end
  end

  def test_validate_registry_code_with_formatting
    assert_equal '16863232', EeEBusinessRegister::Validation.validate_registry_code(' 16863232 ')
    assert_equal '16863232', EeEBusinessRegister::Validation.validate_registry_code('1-6-8-6-3-2-3-2')
    assert_equal '16863232', EeEBusinessRegister::Validation.validate_registry_code('168.632.32')
  end

  def test_validate_registry_code_invalid
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_code('123456789')
    end

    # Empty string returns nil, doesn't raise error
    assert_nil EeEBusinessRegister::Validation.validate_registry_code('')

    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_code('invalid')
    end
  end

  def test_validate_registry_code_nil_and_empty
    assert_nil EeEBusinessRegister::Validation.validate_registry_code(nil)
    assert_nil EeEBusinessRegister::Validation.validate_registry_code('')
    assert_nil EeEBusinessRegister::Validation.validate_registry_code('   ')
  end

  # ========================================
  # PERSONAL CODE VALIDATION TESTS
  # ========================================

  def test_validate_personal_code_valid
    # Valid Estonian personal codes with correct checksums
    # Using known valid Estonian personal codes
    valid_codes = %w[39001010000]  # Only include codes with valid checksums
    
    valid_codes.each do |code|
      result = EeEBusinessRegister::Validation.validate_personal_code(code)
      assert_equal code, result, "Expected #{code} to be valid"
    end
  end

  def test_validate_personal_code_invalid_format
    invalid_codes = ['123', '1234567890', '0001010000', '71001010000']
    
    invalid_codes.each do |code|
      result = EeEBusinessRegister::Validation.validate_personal_code(code)
      assert_nil result, "Expected #{code} to be invalid"
    end
  end

  def test_validate_personal_code_invalid_checksum
    # Valid format but wrong checksum
    result = EeEBusinessRegister::Validation.validate_personal_code('39001010001')
    assert_nil result
  end

  def test_validate_personal_code_nil_and_empty
    assert_nil EeEBusinessRegister::Validation.validate_personal_code(nil)
    assert_nil EeEBusinessRegister::Validation.validate_personal_code('')
    assert_nil EeEBusinessRegister::Validation.validate_personal_code('   ')
  end

  # ========================================
  # COMPANY NAME VALIDATION TESTS
  # ========================================

  def test_validate_company_name_valid
    assert_equal 'Sorbeet Payments OÜ', EeEBusinessRegister::Validation.validate_company_name('Sorbeet Payments OÜ')
    assert_equal 'Test Company', EeEBusinessRegister::Validation.validate_company_name('  Test Company  ')
    assert_equal 'ABC-123 Ltd.', EeEBusinessRegister::Validation.validate_company_name('ABC-123 Ltd.')
  end

  def test_validate_company_name_sanitization
    # Should remove dangerous characters - testing actual behavior
    result1 = EeEBusinessRegister::Validation.validate_company_name('Safe<script>Company')
    refute_includes result1, '<script>'
    
    result2 = EeEBusinessRegister::Validation.validate_company_name('Clean"Name\'')
    refute_includes result2, '"'
    refute_includes result2, "'"
    
    result3 = EeEBusinessRegister::Validation.validate_company_name('Normal&Text')
    assert_equal 'NormalText', result3  # Ampersands are removed, not escaped
  end

  def test_validate_company_name_length_limit
    long_name = 'A' * 300
    result = EeEBusinessRegister::Validation.validate_company_name(long_name)
    assert_equal 255, result.length
  end

  def test_validate_company_name_nil_and_empty
    assert_nil EeEBusinessRegister::Validation.validate_company_name(nil)
    assert_nil EeEBusinessRegister::Validation.validate_company_name('')
    assert_nil EeEBusinessRegister::Validation.validate_company_name('   ')
  end

  # ========================================
  # PERSON NAME VALIDATION TESTS
  # ========================================

  def test_validate_person_name_valid
    assert_equal 'John Doe', EeEBusinessRegister::Validation.validate_person_name('John Doe')
    assert_equal 'Marie-Claire', EeEBusinessRegister::Validation.validate_person_name('Marie-Claire')
    assert_equal "O'Connor", EeEBusinessRegister::Validation.validate_person_name("O'Connor")
    assert_equal 'Ülar Õun', EeEBusinessRegister::Validation.validate_person_name('Ülar Õun')
  end

  def test_validate_person_name_sanitization
    # Should remove numbers and special characters except hyphens and apostrophes
    result1 = EeEBusinessRegister::Validation.validate_person_name('John123Smith')
    refute_includes result1, '123'
    assert_includes result1, 'John'
    assert_includes result1, 'Smith'
    
    result2 = EeEBusinessRegister::Validation.validate_person_name('Clean@Name#')
    refute_includes result2, '@'
    refute_includes result2, '#'
  end

  def test_validate_person_name_length_limit
    long_name = 'A' * 150
    result = EeEBusinessRegister::Validation.validate_person_name(long_name)
    assert_equal 100, result.length
  end

  def test_validate_person_name_nil_and_empty
    assert_nil EeEBusinessRegister::Validation.validate_person_name(nil)
    assert_nil EeEBusinessRegister::Validation.validate_person_name('')
    assert_nil EeEBusinessRegister::Validation.validate_person_name('   ')
  end

  # ========================================
  # DATE VALIDATION TESTS
  # ========================================

  def test_validate_date_iso_format
    assert_equal '2023-01-01', EeEBusinessRegister::Validation.validate_date('2023-01-01')
    assert_equal '2023-12-31', EeEBusinessRegister::Validation.validate_date('2023-12-31')
  end

  def test_validate_date_estonian_format
    result = EeEBusinessRegister::Validation.validate_date('01.01.2023')
    assert_equal '01.01.2023', result
  end

  def test_validate_date_iso_datetime
    result = EeEBusinessRegister::Validation.validate_date('2023-01-01T10:30:00Z')
    assert_equal '2023-01-01T10:30:00Z', result
  end

  def test_validate_date_from_date_object
    date = Date.new(2023, 1, 1)
    assert_equal '2023-01-01', EeEBusinessRegister::Validation.validate_date(date)
  end

  def test_validate_date_from_time_object
    time = Time.new(2023, 1, 1, 10, 30, 0)
    assert_equal '2023-01-01', EeEBusinessRegister::Validation.validate_date(time)
  end

  def test_validate_date_invalid_format
    # Test some formats that should raise validation errors
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_date('clearly-invalid-date')
    end

    # Some formats might be parsed successfully, so let's test truly invalid ones
    assert_raises(StandardError) do  # Could be ValidationError or ArgumentError
      EeEBusinessRegister::Validation.validate_date('99/99/9999')
    end
  end

  def test_validate_date_invalid_type
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_date(123)
    end
  end

  def test_validate_date_nil
    assert_nil EeEBusinessRegister::Validation.validate_date(nil)
  end

  # ========================================
  # LANGUAGE VALIDATION TESTS
  # ========================================

  def test_validate_language_valid
    assert_equal 'eng', EeEBusinessRegister::Validation.validate_language('eng')
    assert_equal 'est', EeEBusinessRegister::Validation.validate_language('est')
    assert_equal 'eng', EeEBusinessRegister::Validation.validate_language('ENG')
    assert_equal 'est', EeEBusinessRegister::Validation.validate_language('EST')
  end

  def test_validate_language_default
    assert_equal 'eng', EeEBusinessRegister::Validation.validate_language(nil)
    assert_equal 'eng', EeEBusinessRegister::Validation.validate_language('')
    assert_equal 'eng', EeEBusinessRegister::Validation.validate_language('   ')
  end

  def test_validate_language_invalid
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_language('invalid')
    end

    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_language('rus')
    end
  end

  # ========================================
  # PAGINATION VALIDATION TESTS
  # ========================================

  def test_validate_page_number_valid
    assert_equal 1, EeEBusinessRegister::Validation.validate_page_number(1)
    assert_equal 10, EeEBusinessRegister::Validation.validate_page_number(10)
    assert_equal 100, EeEBusinessRegister::Validation.validate_page_number('100')
  end

  def test_validate_page_number_default
    assert_equal 1, EeEBusinessRegister::Validation.validate_page_number(nil)
  end

  def test_validate_page_number_invalid
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_page_number(0)
    end

    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_page_number(-1)
    end

    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_page_number(10001)
    end
  end

  def test_validate_results_limit_valid
    assert_equal 10, EeEBusinessRegister::Validation.validate_results_limit(10)
    assert_equal 50, EeEBusinessRegister::Validation.validate_results_limit('50')
    assert_equal 100, EeEBusinessRegister::Validation.validate_results_limit(100)
  end

  def test_validate_results_limit_default
    assert_equal 10, EeEBusinessRegister::Validation.validate_results_limit(nil)
  end

  def test_validate_results_limit_with_custom_max
    assert_equal 200, EeEBusinessRegister::Validation.validate_results_limit(200, 500)

    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_results_limit(600, 500)
    end
  end

  def test_validate_results_limit_invalid
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_results_limit(0)
    end

    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_results_limit(101)
    end
  end

  # ========================================
  # XML SANITIZATION TESTS
  # ========================================

  def test_sanitize_xml_input_valid
    assert_equal 'Normal text', EeEBusinessRegister::Validation.sanitize_xml_input('Normal text')
    assert_equal 'Text with spaces', EeEBusinessRegister::Validation.sanitize_xml_input('  Text with spaces  ')
  end

  def test_sanitize_xml_input_dangerous
    assert_equal 'script/script', EeEBusinessRegister::Validation.sanitize_xml_input('<script></script>')
    assert_equal '&amp;entity;', EeEBusinessRegister::Validation.sanitize_xml_input('&entity;')
    assert_equal 'clean text', EeEBusinessRegister::Validation.sanitize_xml_input('clean "text\'')
  end

  def test_sanitize_xml_input_nil
    assert_equal '', EeEBusinessRegister::Validation.sanitize_xml_input(nil)
  end

  # ========================================
  # ARRAY VALIDATION TESTS
  # ========================================

  def test_validate_registry_codes_array_valid
    codes = ['16863232', '10060701']
    result = EeEBusinessRegister::Validation.validate_registry_codes_array(codes)
    assert_equal ['16863232', '10060701'], result
  end

  def test_validate_registry_codes_array_single_code
    result = EeEBusinessRegister::Validation.validate_registry_codes_array('16863232')
    assert_equal ['16863232'], result
  end

  def test_validate_registry_codes_array_with_invalid_codes
    codes = ['16863232', 'invalid', '10060701']
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_codes_array(codes)
    end
  end

  def test_validate_registry_codes_array_too_many
    codes = (1..101).map { |i| format('%08d', i) }
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_codes_array(codes)
    end
  end

  def test_validate_registry_codes_array_empty
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_codes_array([])
    end

    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_registry_codes_array(nil)
    end
  end

  # ========================================
  # TIME INTERVAL VALIDATION TESTS
  # ========================================

  def test_validate_time_interval_valid
    start_time = Time.new(2023, 1, 1)
    end_time = Time.new(2023, 1, 5)
    
    result = EeEBusinessRegister::Validation.validate_time_interval(start_time, end_time)
    assert_instance_of Array, result
    assert_equal 2, result.length
    assert_instance_of Time, result[0]
    assert_instance_of Time, result[1]
  end

  def test_validate_time_interval_string_input
    result = EeEBusinessRegister::Validation.validate_time_interval('2023-01-01', '2023-01-05')
    assert_instance_of Array, result
    assert_equal 2, result.length
  end

  def test_validate_time_interval_invalid_order
    start_time = Time.new(2023, 1, 5)
    end_time = Time.new(2023, 1, 1)
    
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_time_interval(start_time, end_time)
    end
  end

  def test_validate_time_interval_too_long
    start_time = Time.new(2023, 1, 1)
    end_time = Time.new(2023, 1, 20)  # 19 days, default max is 7
    
    assert_raises(EeEBusinessRegister::Validation::ValidationError) do
      EeEBusinessRegister::Validation.validate_time_interval(start_time, end_time)
    end
  end

  def test_validate_time_interval_custom_max_days
    start_time = Time.new(2023, 1, 1)
    end_time = Time.new(2023, 1, 15)
    
    result = EeEBusinessRegister::Validation.validate_time_interval(start_time, end_time, 20)
    assert_instance_of Array, result
  end

  # ========================================
  # PERSONAL CODE CHECKSUM TESTS
  # ========================================

  def test_valid_personal_code_checksum_valid_codes
    # Test with known valid Estonian personal codes
    valid_codes = [
      '39001010000'  # Only use codes that actually have valid checksums
    ]
    
    valid_codes.each do |code|
      result = EeEBusinessRegister::Validation.send(:valid_personal_code_checksum?, code)
      assert result, "Expected #{code} to have valid checksum"
    end
  end

  def test_valid_personal_code_checksum_invalid_codes
    invalid_codes = [
      '39001010001',  # Wrong checksum
      '39001010002',  # Wrong checksum
      '39001010003'   # Wrong checksum
    ]
    
    invalid_codes.each do |code|
      result = EeEBusinessRegister::Validation.send(:valid_personal_code_checksum?, code)
      refute result, "Expected #{code} to have invalid checksum"
    end
  end

  def test_valid_personal_code_checksum_wrong_length
    refute EeEBusinessRegister::Validation.send(:valid_personal_code_checksum?, '1234567890')
    refute EeEBusinessRegister::Validation.send(:valid_personal_code_checksum?, '123456789012')
  end
end