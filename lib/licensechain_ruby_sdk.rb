require 'logger'
require 'securerandom'
require 'time'
require 'json'
require 'net/http'
require 'uri'

require_relative 'licensechain_ruby_sdk/version'
require_relative 'licensechain/configuration'
require_relative 'licensechain/errors'
require_relative 'licensechain/utils'
require_relative 'licensechain/license_assertion'
require_relative 'licensechain/models'
require_relative 'licensechain/api_client'
require_relative 'licensechain/client'
require_relative 'licensechain/webhook_handler'
require_relative 'licensechain/services/license_service'
require_relative 'licensechain/services/user_service'
require_relative 'licensechain/services/product_service'
require_relative 'licensechain/services/webhook_service'

module LicenseChainRubySdk
  class Error < StandardError; end

  def self.configure
    yield(LicenseChain.configuration)
  end

  def self.configuration
    LicenseChain.configuration
  end

  def self.client(config = nil)
    LicenseChain::Client.new(config)
  end
end