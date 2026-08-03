module LicenseChain
  module Services
    class WebhookService
      def initialize(client)
        @client = client
      end

      def create(url, events, secret = nil)
        validate_webhook_params(url, events)
        
        data = {
          url: url,
          events: events,
          secret: secret
        }

        response = @client.post('/webhooks', data)
        Webhook.new(normalize_webhook_payload(response[:data] || response))
      end

      def get(webhook_id)
        validate_uuid(webhook_id, 'webhook_id')
        
        response = @client.get("/webhooks/#{webhook_id}")
        Webhook.new(normalize_webhook_payload(response[:data] || response))
      end

      def update(webhook_id, updates = {})
        validate_uuid(webhook_id, 'webhook_id')
        
        response = @client.put("/webhooks/#{webhook_id}", Utils.sanitize_metadata(updates))
        Webhook.new(normalize_webhook_payload(response[:data] || response))
      end

      def delete(webhook_id)
        validate_uuid(webhook_id, 'webhook_id')
        
        @client.delete("/webhooks/#{webhook_id}")
        true
      end

      def list
        response = @client.get('/webhooks')
        (response[:data] || []).map { |webhook| Webhook.new(normalize_webhook_payload(webhook)) }
      end

      private

      def validate_webhook_params(url, events)
        Utils.validate_not_empty(url, 'url')
        raise ValidationError, 'Events must be an array' unless events.is_a?(Array)
        raise ValidationError, 'Events cannot be empty' if events.empty?
      end

      def validate_uuid(id, field_name)
        Utils.validate_not_empty(id, field_name)
        raise ValidationError, "Invalid #{field_name} format" unless Utils.validate_uuid(id)
      end

      def normalize_webhook_payload(payload)
        {
          id: payload[:id],
          app_id: payload[:app_id] || '',
          url: payload[:url] || '',
          events: payload[:events] || [],
          secret: payload[:secret],
          status: ((payload[:active].nil? || payload[:active]) ? 'active' : 'inactive'),
          created_at: payload[:created_at] || payload[:createdAt],
          updated_at: payload[:updated_at] || payload[:updatedAt]
        }
      end
    end
  end
end
