# frozen_string_literal: true

module LicenseChain
  class LicenseValidator
    attr_reader :client

    def initialize(api_key: nil, base_url: nil, timeout: nil, retry_attempts: nil)
      @client = Client.new(
        api_key: api_key,
        base_url: base_url,
        timeout: timeout,
        retry_attempts: retry_attempts
      )
    end

    # Validate a license key
    def validate_license(license_key, app_id: nil)
      response = @client.validate_license(license_key, app_id: app_id)
      
      ValidationResult.new(
        valid: response["valid"],
        license: response["license"],
        user: response["user"],
        app: response["app"],
        expires_at: response["expires_at"],
        metadata: response["metadata"],
        error: response["error"]
      )
    end

    # Check if license is valid without full validation
    def valid?(license_key, app_id: nil)
      result = validate_license(license_key, app_id: app_id)
      result.valid?
    end

    # Get license information
    def get_license_info(license_key, app_id: nil)
      result = validate_license(license_key, app_id: app_id)
      result.license
    end

    # Check if license is expired
    def expired?(license_key, app_id: nil)
      result = validate_license(license_key, app_id: app_id)
      return true unless result.valid?
      
      return false unless result.expires_at
      
      Time.parse(result.expires_at) < Time.now
    end

    # Get days until expiration
    def days_until_expiration(license_key, app_id: nil)
      result = validate_license(license_key, app_id: app_id)
      return nil unless result.valid? && result.expires_at
      
      expires_at = Time.parse(result.expires_at)
      ((expires_at - Time.now) / 1.day).ceil
    end

    # Batch validate multiple licenses
    def validate_licenses(license_keys, app_id: nil)
      license_keys.map do |license_key|
        validate_license(license_key, app_id: app_id)
      end
    end

    # Validate with custom validation rules
    def validate_with_rules(license_key, app_id: nil, rules: {})
      result = validate_license(license_key, app_id: app_id)
      return result unless result.valid?

      # Apply custom validation rules
      if rules[:max_usage] && result.license&.dig("usage_count").to_i > rules[:max_usage]
        result.instance_variable_set(:@valid, false)
        result.instance_variable_set(:@error, "Usage limit exceeded")
      end

      if rules[:allowed_features] && result.license&.dig("features")
        allowed_features = rules[:allowed_features]
        license_features = result.license["features"] || []
        invalid_features = license_features - allowed_features
        
        if invalid_features.any?
          result.instance_variable_set(:@valid, false)
          result.instance_variable_set(:@error, "Invalid features: #{invalid_features.join(', ')}")
        end
      end

      result
    end
  end

  # Result object for license validation
  class ValidationResult
    attr_reader :valid, :license, :user, :app, :expires_at, :metadata, :error

    def initialize(valid:, license: nil, user: nil, app: nil, expires_at: nil, metadata: nil, error: nil)
      @valid = valid
      @license = license
      @user = user
      @app = app
      @expires_at = expires_at
      @metadata = metadata || {}
      @error = error
    end

    def valid?
      @valid
    end

    def invalid?
      !@valid
    end

    def expired?
      return false unless @expires_at
      Time.parse(@expires_at) < Time.now
    end

    def user_email
      @user&.dig("email")
    end

    def user_name
      @user&.dig("name")
    end

    def app_name
      @app&.dig("name")
    end

    def license_key
      @license&.dig("key")
    end

    def license_id
      @license&.dig("id")
    end

    def features
      @license&.dig("features") || []
    end

    def usage_count
      @license&.dig("usage_count") || 0
    end

    def created_at
      @license&.dig("created_at")
    end

    def updated_at
      @license&.dig("updated_at")
    end

    def to_h
      {
        valid: @valid,
        license: @license,
        user: @user,
        app: @app,
        expires_at: @expires_at,
        metadata: @metadata,
        error: @error
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end
  end
end
