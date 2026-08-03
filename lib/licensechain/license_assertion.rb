# frozen_string_literal: true

require 'jwt'
require 'json'
require 'uri'
require 'net/http'

module LicenseChain
  # RS256 license_token verification via JWKS (parity with Node verifyLicenseAssertionJwt).
  module LicenseAssertion
    LICENSE_TOKEN_USE_CLAIM = 'licensechain_license_v1'

    module_function

    # @param expected_app_id [String, nil]
    # @param issuer [String, nil]
    # @return [Hash] decoded JWT payload
    def verify_license_assertion_jwt(token, jwks_url, expected_app_id: nil, issuer: nil)
      token = token.to_s.strip
      raise ArgumentError, 'empty token' if token.empty?

      jwks_url = jwks_url.to_s.strip
      raise ArgumentError, 'empty jwks_url' if jwks_url.empty?

      jwks = fetch_jwks(jwks_url)
      decode_opts = {
        algorithms: ['RS256'],
        jwks: jwks,
        verify_aud: false
      }
      if issuer && !issuer.to_s.strip.empty?
        decode_opts[:verify_iss] = true
        decode_opts[:iss] = issuer.to_s.strip
      end

      payload, = JWT.decode(token, nil, true, decode_opts)

      tu = payload['token_use']
      if tu != LICENSE_TOKEN_USE_CLAIM
        raise JWT::DecodeError, %(Invalid license token: expected token_use "#{LICENSE_TOKEN_USE_CLAIM}")
      end

      if expected_app_id && !expected_app_id.to_s.strip.empty?
        want = expected_app_id.to_s.strip
        aud = payload['aud']
        ok = aud == want || (aud.is_a?(Array) && aud.include?(want))
        raise JWT::DecodeError, 'Invalid license token: aud does not match expected app id' unless ok
      end

      payload
    end

    def fetch_jwks(jwks_url)
      uri = URI.parse(jwks_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 20
      http.read_timeout = 20
      req = Net::HTTP::Get.new(uri.request_uri)
      res = http.request(req)
      raise JWT::DecodeError, "JWKS HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body)
    end
    private_class_method :fetch_jwks
  end
end
