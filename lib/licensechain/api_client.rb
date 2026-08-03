require 'net/http'
require 'uri'
require 'json'
require 'timeout'

module LicenseChain
  class ApiClient
    include Utils

    def initialize(config = nil)
      @config = config || LicenseChain.configuration
      raise ConfigurationError, "API key is required" unless @config.valid?
    end

    def get(endpoint, params = {})
      make_request(:get, endpoint, nil, params)
    end

    def post(endpoint, data = nil)
      make_request(:post, endpoint, data)
    end

    def put(endpoint, data = nil)
      make_request(:put, endpoint, data)
    end

    def patch(endpoint, data = nil)
      make_request(:patch, endpoint, data)
    end

    def delete(endpoint, data = nil)
      make_request(:delete, endpoint, data)
    end

    private

    def make_request(method, endpoint, data = nil, params = {})
      uri = build_uri(endpoint, params)
      request = build_request(method, uri, data)
      
      retry_with_backoff(@config.retries) do
        response = send_request(uri, request)
        handle_response(response)
      end
    rescue Timeout::Error
      raise TimeoutError, "Request timed out"
    rescue => e
      raise NetworkError, "Network error: #{e.message}"
    end

    def build_uri(endpoint, params = {})
      base_url = @config.base_url.sub(%r{/\z}, '')
      base_has_v1 = base_url.end_with?('/v1')
      normalized_endpoint = if endpoint.start_with?('/v1/')
        base_has_v1 ? endpoint.sub(%r{\A/v1}, '') : endpoint
      elsif endpoint.start_with?('/')
        base_has_v1 ? endpoint : "/v1#{endpoint}"
      else
        base_has_v1 ? "/#{endpoint}" : "/v1/#{endpoint}"
      end

      uri = URI.parse("#{base_url}#{normalized_endpoint}")
      uri.query = URI.encode_www_form(params) unless params.empty?
      uri
    end

    def build_request(method, uri, data = nil)
      case method
      when :get
        Net::HTTP::Get.new(uri)
      when :post
        request = Net::HTTP::Post.new(uri)
        request.body = data.to_json if data
        request
      when :put
        request = Net::HTTP::Put.new(uri)
        request.body = data.to_json if data
        request
      when :patch
        request = Net::HTTP::Patch.new(uri)
        request.body = data.to_json if data
        request
      when :delete
        request = Net::HTTP::Delete.new(uri)
        request.body = data.to_json if data
        request
      else
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end.tap do |request|
        add_headers(request)
      end
    end

    def add_headers(request)
      request['Authorization'] = "Bearer #{@config.api_key}"
      request['Content-Type'] = 'application/json'
      request['X-API-Version'] = '1.0'
      request['X-Platform'] = 'ruby-sdk'
      request['User-Agent'] = "LicenseChain-Ruby-SDK/1.0.0"
    end

    def send_request(uri, request)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.read_timeout = @config.timeout
        http.open_timeout = @config.timeout
        http.request(request)
      end
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        parse_response(response)
      when 400
        raise ValidationError, "Bad Request: #{response.body}"
      when 401
        raise AuthenticationError, "Unauthorized: #{response.body}"
      when 403
        raise AuthenticationError, "Forbidden: #{response.body}"
      when 404
        raise NotFoundError, "Not Found: #{response.body}"
      when 429
        raise RateLimitError, "Rate Limited: #{response.body}"
      when 500..599
        raise ApiError, "Server Error: #{response.body}"
      else
        raise UnknownError, "Unexpected response: #{response.code} #{response.body}"
      end
    end

    def parse_response(response)
      return {} if response.body.nil? || response.body.empty?
      
      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError => e
      raise DeserializationError, "Failed to parse JSON response: #{e.message}"
    end
  end
end
