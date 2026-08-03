module LicenseChain
  module Services
    class ProductService
      def initialize(client)
        @client = client
      end

      def create(name, description = nil, price = nil, currency = 'USD', metadata = {})
        validate_required_params(name, price, currency)
        raise ValidationError, 'Product endpoints are not available in API v1'
      end

      def get(product_id)
        raise ValidationError, 'Product endpoints are not available in API v1'
      end

      def update(product_id, updates = {})
        raise ValidationError, 'Product endpoints are not available in API v1'
      end

      def delete(product_id)
        raise ValidationError, 'Product endpoints are not available in API v1'
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
        ProductStats.new({ total: 0, active: 0, revenue: 0 })
      end

      private

      def validate_required_params(name, price, currency)
        Utils.validate_not_empty(name, 'name')
        Utils.validate_positive(price, 'price')
        raise ValidationError, 'Invalid currency' unless Utils.validate_currency(currency)
      end

    end
  end
end
