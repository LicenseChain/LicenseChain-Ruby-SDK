require_relative 'configuration'
require_relative 'api_client'
require_relative 'services/license_service'
require_relative 'services/user_service'
require_relative 'services/product_service'
require_relative 'services/webhook_service'
require_relative 'models'
require_relative 'errors'
require_relative 'utils'

module LicenseChain
  class Client
    attr_reader :licenses, :users, :products, :webhooks

    def initialize(config = nil)
      @config = config || LicenseChain.configuration
      @api_client = ApiClient.new(@config)
      
      @licenses = Services::LicenseService.new(@api_client)
      @users = Services::UserService.new(@api_client)
      @products = Services::ProductService.new(@api_client)
      @webhooks = Services::WebhookService.new(@api_client)
    end

    def configuration
      @config
    end

    def ping
      @api_client.get('/health')
    end

    def health
      @api_client.get('/health')
    end
  end
end