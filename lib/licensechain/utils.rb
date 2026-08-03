module LicenseChain
  module Utils
    def self.validate_email(email)
      email_regex = /\A[^\s@]+@[^\s@]+\.[^\s@]+\z/
      email_regex.match?(email)
    end

    def self.validate_license_key(license_key)
      return false if license_key.nil? || license_key.length != 32
      license_key.match?(/\A[A-Z0-9]+\z/)
    end

    def self.validate_uuid(uuid)
      uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i
      uuid_regex.match?(uuid)
    end

    def self.validate_amount(amount)
      amount.is_a?(Numeric) && amount > 0 && amount.finite?
    end

    def self.validate_currency(currency)
      valid_currencies = %w[USD EUR GBP CAD AUD JPY CHF CNY]
      valid_currencies.include?(currency.upcase)
    end

    def self.validate_status(status, allowed_statuses)
      allowed_statuses.include?(status)
    end

    def self.sanitize_input(input)
      return input unless input.is_a?(String)
      input.gsub(/[<>&"']/, {
        '<' => '&lt;',
        '>' => '&gt;',
        '&' => '&amp;',
        '"' => '&quot;',
        "'" => '&#x27;'
      })
    end

    def self.sanitize_metadata(metadata)
      return metadata unless metadata.is_a?(Hash)
      metadata.transform_values do |value|
        if value.is_a?(String)
          sanitize_input(value)
        else
          value
        end
      end
    end

    def self.generate_license_key
      charset = ('A'..'Z').to_a + ('0'..'9').to_a
      (0...32).map { charset.sample }.join
    end

    def self.generate_uuid
      SecureRandom.uuid
    end

    def self.format_timestamp(timestamp)
      Time.at(timestamp).utc.iso8601
    end

    def self.parse_timestamp(timestamp)
      Time.parse(timestamp).to_i
    rescue ArgumentError
      raise ValidationError, "Invalid timestamp format: #{timestamp}"
    end

    def self.validate_pagination(page, limit)
      page = [page || 1, 1].max
      limit = [[limit || 10, 1].max, 100].min
      [page, limit]
    end

    def self.validate_date_range(start_date, end_date)
      start_time = parse_timestamp(start_date)
      end_time = parse_timestamp(end_date)
      
      if start_time > end_time
        raise ValidationError, "Start date must be before or equal to end date"
      end
    rescue ValidationError
      raise
    rescue => e
      raise ValidationError, "Invalid date format: #{e.message}"
    end

    def self.create_webhook_signature(payload, secret)
      require 'openssl'
      digest = OpenSSL::Digest.new('sha256')
      OpenSSL::HMAC.hexdigest(digest, secret, payload)
    end

    def self.verify_webhook_signature(payload, signature, secret)
      expected_signature = create_webhook_signature(payload, secret)
      require 'securerandom'
      SecureRandom.secure_compare(signature, expected_signature)
    end

    def self.default_hwuid
      require 'socket'
      require 'rbconfig'
      require 'digest'
      raw = [
        'licensechain',
        'ruby',
        Socket.gethostname,
        RbConfig::CONFIG['host_os'],
        RbConfig::CONFIG['host_cpu']
      ].join('|')
      Digest::SHA256.hexdigest(raw)
    end

    def self.retry_with_backoff(max_retries = 3, initial_delay = 1.0)
      delay = initial_delay
      
      (0..max_retries).each do |attempt|
        begin
          return yield
        rescue => e
          if attempt == max_retries
            raise e
          end
          
          sleep(delay)
          delay *= 2
        end
      end
    end

    def self.format_bytes(bytes)
      units = %w[B KB MB GB TB PB]
      threshold = 1024
      
      return "#{bytes} B" if bytes < threshold
      
      size = bytes.to_f
      unit_index = 0
      
      while size >= threshold && unit_index < units.length - 1
        size /= threshold
        unit_index += 1
      end
      
      "#{size.round(1)} #{units[unit_index]}"
    end

    def self.format_duration(seconds)
      if seconds < 60
        "#{seconds}s"
      elsif seconds < 3600
        minutes = seconds / 60
        remaining_seconds = seconds % 60
        "#{minutes}m #{remaining_seconds}s"
      elsif seconds < 86400
        hours = seconds / 3600
        minutes = (seconds % 3600) / 60
        "#{hours}h #{minutes}m"
      else
        days = seconds / 86400
        hours = (seconds % 86400) / 3600
        "#{days}d #{hours}h"
      end
    end

    def self.capitalize_first(str)
      return str if str.empty?
      str[0].upcase + str[1..-1].downcase
    end

    def self.to_snake_case(str)
      str.gsub(/([A-Z])/, '_\1').downcase.gsub(/^_/, '')
    end

    def self.to_pascal_case(str)
      str.split('_').map(&:capitalize).join
    end

    def self.truncate_string(str, max_length)
      return str if str.length <= max_length
      "#{str[0...max_length - 3]}..."
    end

    def self.remove_special_chars(str)
      str.gsub(/[^a-zA-Z0-9\s]/, '')
    end

    def self.slugify(str)
      str.downcase
          .gsub(/[^a-z0-9\s-]/, '')
          .gsub(/\s+/, '-')
          .gsub(/-+/, '-')
          .gsub(/^-|-$/, '')
    end

    def self.validate_not_empty(str, field_name)
      raise ValidationError, "#{field_name} cannot be empty" if str.nil? || str.strip.empty?
    end

    def self.validate_positive(number, field_name)
      raise ValidationError, "#{field_name} must be positive" if number.nil? || number <= 0
    end

    def self.validate_range(number, min, max, field_name)
      raise ValidationError, "#{field_name} must be between #{min} and #{max}" if number < min || number > max
    end
  end
end
