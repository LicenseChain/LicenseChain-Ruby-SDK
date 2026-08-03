# frozen_string_literal: true

require "test_helper"
require "webmock/rspec"

RSpec.describe LicenseChain do
  let(:api_key) { "test_api_key_123" }
  let(:client) { LicenseChain::Client.new(api_key: api_key) }

  before do
    LicenseChain.configure do |config|
      config.api_key = api_key
      config.base_url = "https://api.licensechain.app/v1"
    end
  end

  describe "Client" do
    describe "#validate_license" do
      it "validates a license successfully" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .with(
            body: { key: "test_license_key" }.to_json,
            headers: {
              "Authorization" => "Bearer #{api_key}",
              "Content-Type" => "application/json"
            }
          )
          .to_return(
            status: 200,
            body: {
              valid: true,
              license: {
                id: "lic_123",
                key: "test_license_key",
                status: "active",
                expires_at: "2024-12-31T23:59:59Z"
              },
              user: {
                id: "user_123",
                email: "test@example.com",
                name: "Test User"
              }
            }.to_json
          )

        result = client.validate_license("test_license_key")
        expect(result["valid"]).to be true
        expect(result["license"]["key"]).to eq("test_license_key")
      end

      it "handles invalid license" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .to_return(
            status: 200,
            body: {
              valid: false,
              error: "License not found"
            }.to_json
          )

        result = client.validate_license("invalid_key")
        expect(result["valid"]).to be false
        expect(result["error"]).to eq("License not found")
      end
    end

    describe "#create_license" do
      it "creates a license successfully" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses")
          .with(
            body: {
              app_id: "app_123",
              user_email: "test@example.com",
              user_name: "Test User"
            }.to_json
          )
          .to_return(
            status: 201,
            body: {
              id: "lic_123",
              key: "generated_license_key",
              app_id: "app_123",
              user_email: "test@example.com",
              user_name: "Test User",
              status: "active"
            }.to_json
          )

        result = client.create_license(
          app_id: "app_123",
          user_email: "test@example.com",
          user_name: "Test User"
        )

        expect(result["id"]).to eq("lic_123")
        expect(result["key"]).to eq("generated_license_key")
      end
    end

    describe "#list_licenses" do
      it "lists licenses with pagination" do
        stub_request(:get, "https://api.licensechain.app/v1/licenses")
          .with(query: { page: 1, limit: 20 })
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "lic_123",
                  key: "license_key_1",
                  status: "active"
                },
                {
                  id: "lic_456",
                  key: "license_key_2",
                  status: "active"
                }
              ],
              page: 1,
              limit: 20,
              total: 2,
              total_pages: 1
            }.to_json
          )

        result = client.list_licenses
        expect(result["data"].length).to eq(2)
        expect(result["total"]).to eq(2)
      end
    end

    describe "Error handling" do
      it "raises AuthenticationError for 401" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .to_return(status: 401, body: "Unauthorized")

        expect {
          client.validate_license("test_key")
        }.to raise_error(LicenseChain::AuthenticationError)
      end

      it "raises ValidationError for 400" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .to_return(status: 400, body: "Bad Request")

        expect {
          client.validate_license("test_key")
        }.to raise_error(LicenseChain::ValidationError)
      end

      it "raises NotFoundError for 404" do
        stub_request(:get, "https://api.licensechain.app/v1/licenses/invalid_id")
          .to_return(status: 404, body: "Not Found")

        expect {
          client.get_license("invalid_id")
        }.to raise_error(LicenseChain::NotFoundError)
      end

      it "raises RateLimitError for 429" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .to_return(status: 429, body: "Too Many Requests")

        expect {
          client.validate_license("test_key")
        }.to raise_error(LicenseChain::RateLimitError)
      end
    end
  end

  describe "LicenseValidator" do
    let(:validator) { LicenseChain::LicenseValidator.new(api_key: api_key) }

    describe "#validate_license" do
      it "returns ValidationResult object" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .to_return(
            status: 200,
            body: {
              valid: true,
              license: { key: "test_key" },
              user: { email: "test@example.com" }
            }.to_json
          )

        result = validator.validate_license("test_key")
        expect(result).to be_a(LicenseChain::ValidationResult)
        expect(result.valid?).to be true
        expect(result.license_key).to eq("test_key")
        expect(result.user_email).to eq("test@example.com")
      end
    end

    describe "#valid?" do
      it "returns boolean for license validity" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .to_return(
            status: 200,
            body: { valid: true }.to_json
          )

        expect(validator.valid?("test_key")).to be true
      end
    end

    describe "#expired?" do
      it "checks if license is expired" do
        stub_request(:post, "https://api.licensechain.app/v1/licenses/verify")
          .to_return(
            status: 200,
            body: {
              valid: true,
              expires_at: "2020-01-01T00:00:00Z"
            }.to_json
          )

        expect(validator.expired?("test_key")).to be true
      end
    end
  end

  describe "WebhookVerifier" do
    let(:secret) { "webhook_secret_123" }
    let(:verifier) { LicenseChain::WebhookVerifier.new(secret) }

    describe "#verify_signature" do
      it "verifies valid signature" do
        payload = '{"type":"license.created","data":{"id":"lic_123"}}'
        signature = verifier.generate_signature(payload)
        
        expect(verifier.verify_signature(payload, signature)).to be true
      end

      it "rejects invalid signature" do
        payload = '{"type":"license.created","data":{"id":"lic_123"}}'
        invalid_signature = "sha256=invalid_signature"
        
        expect(verifier.verify_signature(payload, invalid_signature)).to be false
      end
    end

    describe "#parse_payload" do
      it "parses and verifies webhook payload" do
        payload = '{"type":"license.created","data":{"id":"lic_123"}}'
        signature = verifier.generate_signature(payload)
        
        result = verifier.parse_payload(payload, signature)
        expect(result["type"]).to eq("license.created")
        expect(result["data"]["id"]).to eq("lic_123")
      end

      it "raises error for invalid signature" do
        payload = '{"type":"license.created","data":{"id":"lic_123"}}'
        invalid_signature = "sha256=invalid_signature"
        
        expect {
          verifier.parse_payload(payload, invalid_signature)
        }.to raise_error(LicenseChain::ValidationError)
      end
    end
  end
end
