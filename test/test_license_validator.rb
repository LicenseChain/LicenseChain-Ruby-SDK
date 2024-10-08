require 'minitest/autorun'
require_relative '../lib/licensechain/license_validator'

class TestLicenseValidator < Minitest::Test
  def setup
    @validator = LicenseChain::LicenseValidator.new('your_api_key')
  end

  def test_validate_license
    assert_equal true, @validator.validate_license('test_license_key')
  end
end