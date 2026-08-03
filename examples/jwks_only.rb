#!/usr/bin/env ruby
# frozen_string_literal: true

# JWKS-only: verify license_token with token + JWKS URI (parity with Go/Rust/PHP jwks_only).
#   export LICENSECHAIN_LICENSE_TOKEN="eyJ..."
#   export LICENSECHAIN_LICENSE_JWKS_URI="https://api.licensechain.app/v1/licenses/jwks"
#   # optional: LICENSECHAIN_EXPECTED_APP_ID=<uuid>
#   ruby examples/jwks_only.rb

require 'json'
require_relative '../lib/licensechain_ruby_sdk'

token = ENV.fetch('LICENSECHAIN_LICENSE_TOKEN', '').strip
jwks = ENV.fetch('LICENSECHAIN_LICENSE_JWKS_URI', '').strip
if token.empty? || jwks.empty?
  warn 'Set LICENSECHAIN_LICENSE_TOKEN and LICENSECHAIN_LICENSE_JWKS_URI'
  exit 1
end

opts = {}
app = ENV['LICENSECHAIN_EXPECTED_APP_ID']&.strip
opts[:expected_app_id] = app unless app.nil? || app.empty?

payload = LicenseChain::LicenseAssertion.verify_license_assertion_jwt(token, jwks, **opts)
puts JSON.pretty_generate(payload)
