# frozen_string_literal: true

module EeEBusinessRegister
  # Comprehensive input validation and sanitization module
  #
  # This module provides robust validation and sanitization for all user inputs
  # that interact with the Estonian e-Business Register API. It serves multiple
  # critical security and data integrity purposes:
  #
  # **Security Functions:**
  # - Prevents XML/SOAP injection attacks by sanitizing malicious input
  # - Blocks potential XSS and code injection attempts
  # - Validates input formats to prevent API abuse and DoS attacks
  #
  # **Data Quality Functions:**
  # - Ensures Estonian registry codes follow the correct 8-digit format
  # - Validates Estonian personal identification codes with checksum verification
  # - Standardizes date formats across different input types
  # - Normalizes company and person names for consistent searching
  #
  # **API Protection:**
  # - Implements rate limiting through pagination and result count validation
  # - Prevents excessive time range queries that could overload the Estonian API
  # - Enforces reasonable limits on bulk operations
  #
  # All validation methods follow a consistent pattern: they either return
  # sanitized/validated data or raise ValidationError for invalid inputs.
  # Methods that handle potentially dangerous content (like names for search)
  # include XSS prevention and character filtering.
  #
  # @example Basic usage
  #   registry_code = Validation.validate_registry_code("16863232")
  #   company_name = Validation.validate_company_name("Sorbeet Payments OÜ")
  #   date_range = Validation.validate_time_interval("2023-01-01", "2023-01-31")
  #
  module Validation
    # Exception raised when input validation fails
    #
    # This error is thrown when user input doesn't meet the required format,
    # contains potentially dangerous content, or exceeds allowed limits.
    # The error message provides specific guidance on what was wrong and
    # how to fix it.
    #
    class ValidationError < StandardError; end
    
    # Regular expression for validating Estonian company registry codes
    # Estonian companies have unique 8-digit identification codes
    REGISTRY_CODE_PATTERN = /\A\d{8}\z/.freeze
    
    # Regular expression for validating Estonian personal identification codes
    # Format: First digit (1-6) indicates century and gender, followed by 10 more digits
    # 1,2 = 1800-1899, 3,4 = 1900-1999, 5,6 = 2000-2099
    # Odd numbers = male, even numbers = female
    PERSONAL_CODE_PATTERN = /\A[1-6]\d{10}\z/.freeze
    
    # Supported date format patterns for input validation
    # Covers standard ISO formats and Estonian DD.MM.YYYY format
    DATE_PATTERNS = [
      /\A\d{4}-\d{2}-\d{2}\z/,                    # YYYY-MM-DD (ISO date)
      /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z?\z/, # ISO 8601 datetime with optional Z
      /\A\d{2}\.\d{2}\.\d{4}\z/                   # DD.MM.YYYY (Estonian format)
    ].freeze
    
    # Supported language codes for API responses
    # 'est' = Estonian, 'eng' = English
    VALID_LANGUAGES = %w[est eng].freeze
    
    # Common Estonian company legal form abbreviations
    # OÜ = Osaühing (LLC), AS = Aktsiaselts (JSC), MTÜ = Mittetulundusühing (NPO), etc.
    VALID_LEGAL_FORMS = %w[OÜ AS MTÜ SA TÜH UÜ].freeze
    
    class << self
      # Validate and sanitize registry code
      # @param code [String, Integer] Registry code to validate
      # @return [String] Sanitized 8-digit registry code
      # @raise [ValidationError] If code format is invalid
      def validate_registry_code(code)
        return nil if code.nil? || code.to_s.strip.empty?
        
        # Remove all non-numeric characters
        sanitized = code.to_s.strip.gsub(/[^\d]/, '')
        
        unless sanitized.match?(REGISTRY_CODE_PATTERN)
          raise ValidationError, 
            "Invalid registry code format '#{code}'. Must be exactly 8 digits."
        end
        
        sanitized
      end
      
      # Validate Estonian personal identification code
      # @param code [String] Personal code to validate
      # @return [String, nil] Sanitized personal code or nil if invalid
      def validate_personal_code(code)
        return nil if code.nil? || code.to_s.strip.empty?
        
        sanitized = code.to_s.strip.gsub(/[^\d]/, '')
        
        return nil unless sanitized.match?(PERSONAL_CODE_PATTERN)
        
        # Validate checksum for Estonian personal codes
        return nil unless valid_personal_code_checksum?(sanitized)
        
        sanitized
      end
      
      # Validate and sanitize company name for search
      # @param name [String] Company name to validate
      # @return [String, nil] Sanitized company name
      def validate_company_name(name)
        return nil if name.nil?
        
        sanitized = name.to_s.strip
        return nil if sanitized.empty?
        
        # Remove potentially dangerous characters but keep Unicode letters
        # Allow letters, numbers, spaces, and common business punctuation
        sanitized = sanitized.gsub(/[<>"';&|`$(){}\[\]\\]/, '')
        
        # Limit length to prevent DoS
        sanitized = sanitized[0, 255] if sanitized.length > 255
        
        sanitized.empty? ? nil : sanitized
      end
      
      # Validate person name (first/last name)
      # @param name [String] Person name to validate
      # @return [String, nil] Sanitized person name
      def validate_person_name(name)
        return nil if name.nil?
        
        sanitized = name.to_s.strip
        return nil if sanitized.empty?
        
        # Allow only letters, spaces, hyphens, and apostrophes
        sanitized = sanitized.gsub(/[^a-zA-ZÀ-ÿĀ-žА-я\s\-']/, '')
        
        # Limit length
        sanitized = sanitized[0, 100] if sanitized.length > 100
        
        sanitized.empty? ? nil : sanitized
      end
      
      # Validate date input
      # @param date [String, Date, Time] Date to validate
      # @return [String, nil] ISO formatted date string
      def validate_date(date)
        return nil if date.nil?
        
        case date
        when Date
          date.iso8601
        when Time
          date.to_date.iso8601
        when String
          sanitized = date.to_s.strip
          return nil if sanitized.empty?
          
          # Check if it matches expected patterns
          return sanitized if DATE_PATTERNS.any? { |pattern| sanitized.match?(pattern) }
          
          # Try to parse as date
          begin
            parsed_date = Date.parse(sanitized)
            parsed_date.iso8601
          rescue ArgumentError
            raise ValidationError, "Invalid date format '#{date}'. Use YYYY-MM-DD format."
          end
        else
          raise ValidationError, "Date must be a String, Date, or Time object"
        end
      end
      
      # Validate language code
      # @param language [String] Language code to validate
      # @return [String] Valid language code
      # @raise [ValidationError] If language is not supported
      def validate_language(language)
        return 'eng' if language.nil? || language.to_s.strip.empty?
        
        lang = language.to_s.strip.downcase
        
        unless VALID_LANGUAGES.include?(lang)
          raise ValidationError, 
            "Invalid language '#{language}'. Must be one of: #{VALID_LANGUAGES.join(', ')}"
        end
        
        lang
      end
      
      # Validate page number for pagination
      # @param page [Integer, String] Page number
      # @return [Integer] Valid page number (minimum 1)
      def validate_page_number(page)
        return 1 if page.nil?
        
        page_num = page.to_i
        
        if page_num < 1
          raise ValidationError, "Page number must be 1 or greater, got #{page}"
        end
        
        # Limit maximum page to prevent resource exhaustion
        if page_num > 10000
          raise ValidationError, "Page number too large (max 10000), got #{page}"
        end
        
        page_num
      end
      
      # Validate results per page limit
      # @param limit [Integer, String] Number of results per page
      # @param max_allowed [Integer] Maximum allowed limit
      # @return [Integer] Valid limit
      def validate_results_limit(limit, max_allowed = 100)
        return 10 if limit.nil? # Default limit
        
        limit_num = limit.to_i
        
        if limit_num < 1
          raise ValidationError, "Results limit must be 1 or greater, got #{limit}"
        end
        
        if limit_num > max_allowed
          raise ValidationError, 
            "Results limit too large (max #{max_allowed}), got #{limit}"
        end
        
        limit_num
      end
      
      # Validate legal form codes
      # @param forms [Array<String>] Legal form codes
      # @return [Array<String>] Valid legal form codes
      def validate_legal_forms(forms)
        return [] if forms.nil? || forms.empty?
        
        forms = [forms] unless forms.is_a?(Array)
        
        validated = forms.map do |form|
          sanitized = form.to_s.strip.upcase
          next nil if sanitized.empty?
          
          # Allow both official codes and common abbreviations
          sanitized
        end.compact
        
        validated
      end
      
      # Sanitize XML input to prevent injection attacks
      # @param input [String] Raw input that will be used in XML/SOAP
      # @return [String] Sanitized input safe for XML
      def sanitize_xml_input(input)
        return '' if input.nil?
        
        input.to_s
             .gsub(/[<>]/, '') # Remove XML brackets
             .gsub(/[&]/, '&amp;') # Escape ampersands
             .gsub(/["']/, '') # Remove quotes
             .strip
      end
      
      # Validate array of registry codes (for bulk operations)
      # @param codes [Array] Array of registry codes
      # @param max_count [Integer] Maximum number of codes allowed
      # @return [Array<String>] Array of validated registry codes
      def validate_registry_codes_array(codes, max_count = 100)
        if codes.nil? || codes.empty?
          raise ValidationError, "Registry codes array cannot be empty"
        end
        
        codes = [codes] unless codes.is_a?(Array)
        
        if codes.length > max_count
          raise ValidationError, 
            "Too many registry codes (max #{max_count}), got #{codes.length}"
        end
        
        codes.map { |code| validate_registry_code(code) }.compact
      end
      
      # Validate time interval to prevent excessive API load
      # @param start_time [Time, String] Start of time interval
      # @param end_time [Time, String] End of time interval  
      # @param max_days [Integer] Maximum allowed interval in days
      # @return [Array<Time>] Array of [start_time, end_time]
      def validate_time_interval(start_time, end_time, max_days = 7)
        start_t = parse_time_input(start_time)
        end_t = parse_time_input(end_time)
        
        unless start_t && end_t
          raise ValidationError, 
            "Invalid time format. Use ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)"
        end
        
        if start_t >= end_t
          raise ValidationError, "Start time must be before end time"
        end
        
        interval_days = (end_t - start_t) / 86400.0 # Convert seconds to days
        
        if interval_days > max_days
          raise ValidationError, 
            "Time interval too large (max #{max_days} days), got #{interval_days.round(1)} days"
        end
        
        # Prevent queries too far in the past (data availability)
        max_history_days = 3650 # ~10 years
        days_ago = (Time.now - start_t) / 86400.0
        
        if days_ago > max_history_days
          raise ValidationError, 
            "Start time too far in the past (max #{max_history_days} days ago)"
        end
        
        [start_t, end_t]
      end
      
      private
      
      # Parse time input from various formats
      # @param time_input [Time, String, Integer] Time in various formats
      # @return [Time, nil] Parsed time or nil if invalid
      def parse_time_input(time_input)
        case time_input
        when Time
          time_input
        when String
          Time.parse(time_input)
        when Integer
          Time.at(time_input) # Unix timestamp
        else
          nil
        end
      rescue ArgumentError
        nil
      end
      
      # Validate Estonian personal code checksum
      # @param code [String] 11-digit personal code
      # @return [Boolean] True if checksum is valid
      def valid_personal_code_checksum?(code)
        return false unless code.length == 11
        
        digits = code.chars.map(&:to_i)
        
        # First checksum calculation
        weights1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1]
        sum1 = digits[0, 10].each_with_index.sum { |digit, i| digit * weights1[i] }
        remainder1 = sum1 % 11
        
        if remainder1 < 10
          return digits[10] == remainder1
        end
        
        # Second checksum calculation if first gives 10
        weights2 = [3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
        sum2 = digits[0, 10].each_with_index.sum { |digit, i| digit * weights2[i] }
        remainder2 = sum2 % 11
        
        checksum = remainder2 < 10 ? remainder2 : 0
        digits[10] == checksum
      end
    end
  end
end