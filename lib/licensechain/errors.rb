module LicenseChain
  class Error < StandardError; end
  
  class NetworkError < Error; end
  class ApiError < Error; end
  class ValidationError < Error; end
  class AuthenticationError < Error; end
  class NotFoundError < Error; end
  class RateLimitError < Error; end
  class TimeoutError < Error; end
  class SerializationError < Error; end
  class DeserializationError < Error; end
  class ConfigurationError < Error; end
  class UnknownError < Error; end
end
