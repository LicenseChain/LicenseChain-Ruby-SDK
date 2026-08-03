require 'openssl'
require 'json'
require 'time'

module LicenseChain
  class WebhookHandler
    attr_reader :secret, :tolerance

    def initialize(secret, tolerance = 300)
      @secret = secret
      @tolerance = tolerance
    end

    def verify_signature(payload, signature)
      Utils.verify_webhook_signature(payload, signature, @secret)
    end

    def verify_timestamp(timestamp)
      webhook_time = Time.parse(timestamp)
      current_time = Time.now
      time_diff = (current_time - webhook_time).abs

      if time_diff > @tolerance
        raise ValidationError, "Webhook timestamp too old: #{time_diff} seconds"
      end
    rescue ArgumentError => e
      raise ValidationError, "Invalid timestamp format: #{e.message}"
    end

    def verify_webhook(payload, signature, timestamp)
      verify_timestamp(timestamp)
      
      unless verify_signature(payload, signature)
        raise AuthenticationError, "Invalid webhook signature"
      end
    end

    def process_event(event_data)
      payload = event_data[:data].to_json
      verify_webhook(payload, event_data[:signature], event_data[:timestamp])
      
      case event_data[:type]
      when 'license.created'
        handle_license_created(event_data)
      when 'license.updated'
        handle_license_updated(event_data)
      when 'license.revoked'
        handle_license_revoked(event_data)
      when 'license.expired'
        handle_license_expired(event_data)
      when 'user.created'
        handle_user_created(event_data)
      when 'user.updated'
        handle_user_updated(event_data)
      when 'user.deleted'
        handle_user_deleted(event_data)
      when 'product.created'
        handle_product_created(event_data)
      when 'product.updated'
        handle_product_updated(event_data)
      when 'product.deleted'
        handle_product_deleted(event_data)
      when 'payment.completed'
        handle_payment_completed(event_data)
      when 'payment.failed'
        handle_payment_failed(event_data)
      when 'payment.refunded'
        handle_payment_refunded(event_data)
      else
        puts "Unknown webhook event type: #{event_data[:type]}"
      end
    end

    private

    def handle_license_created(event_data)
      puts "License created: #{event_data[:id]}"
      # Add custom logic for license created event
    end

    def handle_license_updated(event_data)
      puts "License updated: #{event_data[:id]}"
      # Add custom logic for license updated event
    end

    def handle_license_revoked(event_data)
      puts "License revoked: #{event_data[:id]}"
      # Add custom logic for license revoked event
    end

    def handle_license_expired(event_data)
      puts "License expired: #{event_data[:id]}"
      # Add custom logic for license expired event
    end

    def handle_user_created(event_data)
      puts "User created: #{event_data[:id]}"
      # Add custom logic for user created event
    end

    def handle_user_updated(event_data)
      puts "User updated: #{event_data[:id]}"
      # Add custom logic for user updated event
    end

    def handle_user_deleted(event_data)
      puts "User deleted: #{event_data[:id]}"
      # Add custom logic for user deleted event
    end

    def handle_product_created(event_data)
      puts "Product created: #{event_data[:id]}"
      # Add custom logic for product created event
    end

    def handle_product_updated(event_data)
      puts "Product updated: #{event_data[:id]}"
      # Add custom logic for product updated event
    end

    def handle_product_deleted(event_data)
      puts "Product deleted: #{event_data[:id]}"
      # Add custom logic for product deleted event
    end

    def handle_payment_completed(event_data)
      puts "Payment completed: #{event_data[:id]}"
      # Add custom logic for payment completed event
    end

    def handle_payment_failed(event_data)
      puts "Payment failed: #{event_data[:id]}"
      # Add custom logic for payment failed event
    end

    def handle_payment_refunded(event_data)
      puts "Payment refunded: #{event_data[:id]}"
      # Add custom logic for payment refunded event
    end
  end

  module WebhookEvents
    LICENSE_CREATED = 'license.created'
    LICENSE_UPDATED = 'license.updated'
    LICENSE_REVOKED = 'license.revoked'
    LICENSE_EXPIRED = 'license.expired'
    USER_CREATED = 'user.created'
    USER_UPDATED = 'user.updated'
    USER_DELETED = 'user.deleted'
    PRODUCT_CREATED = 'product.created'
    PRODUCT_UPDATED = 'product.updated'
    PRODUCT_DELETED = 'product.deleted'
    PAYMENT_COMPLETED = 'payment.completed'
    PAYMENT_FAILED = 'payment.failed'
    PAYMENT_REFUNDED = 'payment.refunded'
  end
end
