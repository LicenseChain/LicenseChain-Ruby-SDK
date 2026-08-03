# frozen_string_literal: true

module LicenseChain
  # Base model class
  class Model
    include Enumerable

    def initialize(attributes = {})
      @attributes = attributes.dup
    end

    def [](key)
      @attributes[key.to_s]
    end

    def []=(key, value)
      @attributes[key.to_s] = value
    end

    def each(&block)
      @attributes.each(&block)
    end

    def keys
      @attributes.keys
    end

    def values
      @attributes.values
    end

    def to_h
      @attributes.dup
    end

    def to_json(*args)
      @attributes.to_json(*args)
    end

    def inspect
      "#<#{self.class.name}:#{object_id} #{@attributes.inspect}>"
    end

    def ==(other)
      other.is_a?(self.class) && @attributes == other.instance_variable_get(:@attributes)
    end

    def method_missing(method_name, *args, &block)
      if @attributes.key?(method_name.to_s)
        @attributes[method_name.to_s]
      elsif @attributes.key?(method_name.to_s.chomp("="))
        @attributes[method_name.to_s.chomp("=")] = args.first
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @attributes.key?(method_name.to_s) || @attributes.key?(method_name.to_s.chomp("=")) || super
    end
  end

  # User model
  class User < Model
    def id
      self["id"]
    end

    def email
      self["email"]
    end

    def name
      self["name"]
    end

    def company
      self["company"]
    end

    def created_at
      Time.parse(self["created_at"]) if self["created_at"]
    end

    def updated_at
      Time.parse(self["updated_at"]) if self["updated_at"]
    end

    def email_verified?
      self["email_verified"] == true
    end

    def active?
      self["status"] == "active"
    end
  end

  # Application model
  class Application < Model
    def id
      self["id"]
    end

    def name
      self["name"]
    end

    def description
      self["description"]
    end

    def api_key
      self["api_key"]
    end

    def webhook_url
      self["webhook_url"]
    end

    def allowed_origins
      self["allowed_origins"] || []
    end

    def created_at
      Time.parse(self["created_at"]) if self["created_at"]
    end

    def updated_at
      Time.parse(self["updated_at"]) if self["updated_at"]
    end

    def active?
      self["status"] == "active"
    end

    def license_count
      self["license_count"] || 0
    end
  end

  # License model
  class License < Model
    def id
      self["id"]
    end

    def key
      self["key"]
    end

    def app_id
      self["app_id"]
    end

    def user_id
      self["user_id"]
    end

    def user_email
      self["user_email"]
    end

    def user_name
      self["user_name"]
    end

    def status
      self["status"]
    end

    def expires_at
      Time.parse(self["expires_at"]) if self["expires_at"]
    end

    def created_at
      Time.parse(self["created_at"]) if self["created_at"]
    end

    def updated_at
      Time.parse(self["updated_at"]) if self["updated_at"]
    end

    def metadata
      self["metadata"] || {}
    end

    def features
      self["features"] || []
    end

    def usage_count
      self["usage_count"] || 0
    end

    def active?
      self["status"] == "active"
    end

    def expired?
      return false unless expires_at
      expires_at < Time.now
    end

    def revoked?
      self["status"] == "revoked"
    end

    def days_until_expiration
      return nil unless expires_at
      ((expires_at - Time.now) / 1.day).ceil
    end
  end

  # Webhook model
  class Webhook < Model
    def id
      self["id"]
    end

    def app_id
      self["app_id"]
    end

    def url
      self["url"]
    end

    def events
      self["events"] || []
    end

    def secret
      self["secret"]
    end

    def active?
      self["status"] == "active"
    end

    def created_at
      Time.parse(self["created_at"]) if self["created_at"]
    end

    def updated_at
      Time.parse(self["updated_at"]) if self["updated_at"]
    end

    def last_triggered_at
      Time.parse(self["last_triggered_at"]) if self["last_triggered_at"]
    end

    def failure_count
      self["failure_count"] || 0
    end
  end

  # Analytics model
  class Analytics < Model
    def total_licenses
      self["total_licenses"] || 0
    end

    def active_licenses
      self["active_licenses"] || 0
    end

    def expired_licenses
      self["expired_licenses"] || 0
    end

    def revoked_licenses
      self["revoked_licenses"] || 0
    end

    def validations_today
      self["validations_today"] || 0
    end

    def validations_this_week
      self["validations_this_week"] || 0
    end

    def validations_this_month
      self["validations_this_month"] || 0
    end

    def top_features
      self["top_features"] || []
    end

    def usage_by_day
      self["usage_by_day"] || []
    end

    def usage_by_week
      self["usage_by_week"] || []
    end

    def usage_by_month
      self["usage_by_month"] || []
    end
  end

  # Paginated response model
  class PaginatedResponse < Model
    def data
      self["data"] || []
    end

    def page
      self["page"] || 1
    end

    def limit
      self["limit"] || 20
    end

    def total
      self["total"] || 0
    end

    def total_pages
      self["total_pages"] || 1
    end

    def has_next_page?
      page < total_pages
    end

    def has_previous_page?
      page > 1
    end

    def next_page
      has_next_page? ? page + 1 : nil
    end

    def previous_page
      has_previous_page? ? page - 1 : nil
    end

    def each(&block)
      data.each(&block)
    end

    def size
      data.size
    end

    def empty?
      data.empty?
    end
  end
end
