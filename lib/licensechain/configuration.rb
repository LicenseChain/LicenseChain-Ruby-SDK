module LicenseChain
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :retries, :logger

    def initialize
      @api_key = ENV['LICENSECHAIN_API_KEY']
      @base_url = ENV['LICENSECHAIN_BASE_URL'] || 'https://api.licensechain.app/v1'
      @timeout = 30
      @retries = 3
      @logger = Logger.new(STDOUT)
    end

    def valid?
      !@api_key.nil? && !@api_key.empty?
    end

    def reset!
      @api_key = nil
      @base_url = 'https://api.licensechain.app/v1'
      @timeout = 30
      @retries = 3
      @logger = Logger.new(STDOUT)
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset!
      @configuration = Configuration.new
    end
  end
end
