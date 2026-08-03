# frozen_string_literal: true

require "openssl"
require "json"

module LicenseChain
  class WebhookVerifier
    attr_reader :secret

    def initialize(secret)
      @secret = secret
    end

    # Verify webhook signature
    def verify_signature(payload, signature, algorithm: "sha256")
      expected_signature = generate_signature(payload, algorithm)
      secure_compare(signature, expected_signature)
    end

    # Parse and verify webhook payload
    def parse_payload(payload, signature, algorithm: "sha256")
      raise ValidationError, "Invalid signature" unless verify_signature(payload, signature, algorithm: algorithm)
      
      JSON.parse(payload)
    rescue JSON::ParserError => e
      raise ValidationError, "Invalid JSON payload: #{e.message}"
    end

    # Generate signature for testing
    def generate_signature(payload, algorithm = "sha256")
      digest = case algorithm.downcase
               when "sha1"
                 OpenSSL::Digest::SHA1
               when "sha256"
                 OpenSSL::Digest::SHA256
               when "sha512"
                 OpenSSL::Digest::SHA512
               else
                 raise ArgumentError, "Unsupported algorithm: #{algorithm}"
               end

      signature = OpenSSL::HMAC.hexdigest(digest.new, @secret, payload)
      "#{algorithm}=#{signature}"
    end

    # Verify webhook event type
    def verify_event_type(payload, expected_type)
      event_type = payload.dig("type") || payload.dig("event")
      event_type == expected_type
    end

    # Extract event data
    def extract_event_data(payload)
      {
        id: payload["id"],
        type: payload["type"] || payload["event"],
        created_at: payload["created_at"],
        data: payload["data"] || payload["object"]
      }
    end

    # Verify webhook timestamp (prevent replay attacks)
    def verify_timestamp(payload, tolerance: 300) # 5 minutes
      timestamp = payload["timestamp"] || payload["created_at"]
      return true unless timestamp

      event_time = Time.parse(timestamp)
      current_time = Time.now
      
      (current_time - event_time).abs <= tolerance
    rescue ArgumentError
      false
    end

    private

    def secure_compare(a, b)
      return false if a.nil? || b.nil?
      return false if a.length != b.length

      result = 0
      a.bytes.zip(b.bytes) { |x, y| result |= x ^ y }
      result == 0
    end
  end

  # Webhook event handler
  class WebhookHandler
    attr_reader :verifier

    def initialize(secret)
      @verifier = WebhookVerifier.new(secret)
    end

    def handle(payload, signature, algorithm: "sha256")
      # Parse and verify the payload
      data = @verifier.parse_payload(payload, signature, algorithm: algorithm)
      
      # Verify timestamp to prevent replay attacks
      unless @verifier.verify_timestamp(data)
        raise ValidationError, "Webhook timestamp is too old"
      end

      # Extract event information
      event_data = @verifier.extract_event_data(data)
      
      # Route to appropriate handler
      handle_event(event_data)
    end

    private

    def handle_event(event_data)
      case event_data[:type]
      when "license.created"
        handle_license_created(event_data)
      when "license.updated"
        handle_license_updated(event_data)
      when "license.revoked"
        handle_license_revoked(event_data)
      when "license.expired"
        handle_license_expired(event_data)
      when "license.validated"
        handle_license_validated(event_data)
      when "app.created"
        handle_app_created(event_data)
      when "app.updated"
        handle_app_updated(event_data)
      when "app.deleted"
        handle_app_deleted(event_data)
      when "user.created"
        handle_user_created(event_data)
      when "user.updated"
        handle_user_updated(event_data)
      else
        handle_unknown_event(event_data)
      end
    end

    def handle_license_created(event_data)
      # Override in subclass
    end

    def handle_license_updated(event_data)
      # Override in subclass
    end

    def handle_license_revoked(event_data)
      # Override in subclass
    end

    def handle_license_expired(event_data)
      # Override in subclass
    end

    def handle_license_validated(event_data)
      # Override in subclass
    end

    def handle_app_created(event_data)
      # Override in subclass
    end

    def handle_app_updated(event_data)
      # Override in subclass
    end

    def handle_app_deleted(event_data)
      # Override in subclass
    end

    def handle_user_created(event_data)
      # Override in subclass
    end

    def handle_user_updated(event_data)
      # Override in subclass
    end

    def handle_unknown_event(event_data)
      # Override in subclass
    end
  end
end
