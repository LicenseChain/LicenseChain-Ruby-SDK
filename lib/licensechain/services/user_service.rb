module LicenseChain
  module Services
    class UserService
      def initialize(client)
        @client = client
      end

      def create(email, name = nil, metadata = {})
        validate_email(email)
        
        data = {
          email: email,
          name: name,
          password: 'ChangeMe123!',
          metadata: Utils.sanitize_metadata(metadata)
        }

        response = @client.post('/auth/register', data)
        User.new(response[:user] || response[:data] || response)
      end

      def get(user_id)
        Utils.validate_not_empty(user_id, 'user_id')
        response = @client.get('/auth/me')
        User.new(response[:data] || response)
      end

      def update(user_id, updates = {})
        raise ValidationError, 'User update endpoint is not available in API v1'
      end

      def delete(user_id)
        raise ValidationError, 'User delete endpoint is not available in API v1'
      end

      def list(page = 1, limit = 10)
        page, limit = Utils.validate_pagination(page, limit)
        {
          data: [],
          total: 0,
          page: page,
          limit: limit
        }
      end

      def stats
        UserStats.new({ total: 0, active: 0, inactive: 0 })
      end

      private

      def validate_email(email)
        Utils.validate_not_empty(email, 'email')
        raise ValidationError, 'Invalid email format' unless Utils.validate_email(email)
      end

    end
  end
end
