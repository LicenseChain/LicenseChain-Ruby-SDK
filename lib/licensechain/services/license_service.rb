module LicenseChain
  module Services
    class LicenseService
      def initialize(client)
        @client = client
      end

      def create(app_id, user_email, metadata = {})
        Utils.validate_not_empty(app_id, 'app_id')
        Utils.validate_not_empty(user_email, 'user_email')
        
        data = {
          appId: app_id,
          plan: 'FREE',
          issuedEmail: user_email,
          metadata: Utils.sanitize_metadata(metadata)
        }

        response = @client.post("/apps/#{app_id}/licenses", data)
        License.new(normalize_license_payload(response[:data] || response))
      end

      def get(license_id)
        Utils.validate_not_empty(license_id, 'license_id')
        
        response = @client.get("/licenses/#{license_id}")
        License.new(normalize_license_payload(response[:data] || response))
      end

      def update(license_id, updates = {})
        Utils.validate_not_empty(license_id, 'license_id')
        
        response = @client.patch("/licenses/#{license_id}", Utils.sanitize_metadata(updates))
        License.new(normalize_license_payload(response[:data] || response))
      end

      def revoke(license_id)
        Utils.validate_not_empty(license_id, 'license_id')
        
        @client.delete("/licenses/#{license_id}")
        true
      end

      def validate(license_key, hwuid = nil)
        Utils.validate_not_empty(license_key, 'license_key')
        body = { key: license_key }
        body[:hwuid] = hwuid.to_s.strip != '' ? hwuid.to_s.strip : Utils.default_hwuid
        response = @client.post('/licenses/verify', body)
        response[:valid]
      end

      # Full POST /licenses/verify body (valid, optional license_token, license_jwks_uri, etc.).
      def verify_with_details(license_key, hwuid = nil)
        Utils.validate_not_empty(license_key, 'license_key')
        body = { key: license_key }
        body[:hwuid] = hwuid.to_s.strip != '' ? hwuid.to_s.strip : Utils.default_hwuid
        @client.post('/licenses/verify', body)
      end

      def list_user_licenses(user_id, page = 1, limit = 10)
        Utils.validate_not_empty(user_id, 'user_id')
        page, limit = Utils.validate_pagination(page, limit)
        
        response = @client.get('/licenses', { page: page, limit: limit })
        items = response[:data] || response[:licenses] || []
        filtered = items.select do |license|
          license[:issuedEmail] == user_id || license[:email] == user_id || license[:user_id] == user_id
        end
        {
          data: filtered.map { |license| License.new(normalize_license_payload(license)) },
          total: filtered.length,
          page: page,
          limit: limit
        }
      end

      def stats
        response = @client.get('/licenses/stats')
        LicenseStats.new(response[:data] || response)
      end

      private

      def validate_uuid(id, field_name)
        Utils.validate_not_empty(id, field_name)
        raise ValidationError, "Invalid #{field_name} format" unless Utils.validate_uuid(id)
      end

      def normalize_license_payload(payload)
        {
          id: payload[:id],
          key: payload[:key] || payload[:licenseKey],
          app_id: payload[:app_id] || payload[:appId] || '',
          user_id: payload[:user_id],
          user_email: payload[:user_email] || payload[:issuedEmail] || payload[:email] || '',
          user_name: payload[:user_name] || payload[:issuedTo],
          status: (payload[:status] || 'active').to_s.downcase,
          expires_at: payload[:expires_at] || payload[:expiresAt],
          created_at: payload[:created_at] || payload[:createdAt],
          updated_at: payload[:updated_at] || payload[:updatedAt],
          metadata: payload[:metadata] || {},
          features: payload[:features] || [],
          usage_count: payload[:usage_count] || 0
        }
      end
    end
  end
end
