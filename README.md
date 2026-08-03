# LicenseChain Ruby SDK

[![License](https://img.shields.io/badge/license-Elastic--2.0-blue.svg)](LICENSE)
[![Ruby](https://img.shields.io/badge/Ruby-3.0+-red.svg)](https://www.ruby-lang.org/)
[![Gem](https://img.shields.io/gem/v/licensechain-sdk)](https://rubygems.org/gems/licensechain-sdk)
[![Downloads](https://img.shields.io/gem/dt/licensechain-sdk)](https://rubygems.org/gems/licensechain-sdk)

Official Ruby SDK for LicenseChain - Secure license management for Ruby applications.

## 🚀 Features

- **🔐 Secure Authentication** - User registration, login, and session management
- **📜 License Management** - Create, validate, update, and revoke licenses
- **🛡️ Hardware ID Validation** - Prevent license sharing and unauthorized access
- **🔔 Webhook Support** - Real-time license events and notifications
- **📊 Analytics Integration** - Track license usage and performance metrics
- **⚡ High Performance** - Optimized for production workloads
- **🔄 Async Operations** - Non-blocking HTTP requests and data processing
- **🛠️ Easy Integration** - Simple API with comprehensive documentation

## 📦 Installation

### Method 1: RubyGems (Recommended)

```bash
# Install via gem
gem install licensechain-sdk

# Or add to Gemfile
gem 'licensechain-sdk', '~> 1.0'
```

### Method 2: Bundler

```bash
# Add to Gemfile
gem 'licensechain-sdk', '~> 1.0'

# Install dependencies
bundle install
```

### Method 3: Manual Installation

1. Download the latest release from [GitHub Releases](https://github.com/LicenseChain/LicenseChain-Ruby-SDK/releases)
2. Extract to your project directory
3. Install dependencies

## 🚀 Quick Start

### Basic Setup

```ruby
require 'licensechain-sdk'

# Initialize the client
client = LicenseChain::Client.new(
  api_key: 'your-api-key',
  app_name: 'your-app-name',
  version: '1.0.0'
)

# Connect to LicenseChain
begin
  client.connect
  puts "Connected to LicenseChain successfully!"
rescue => e
  puts "Failed to connect: #{e.message}"
end
```

### User Authentication

```ruby
# Register a new user
begin
  user = client.register('username', 'password', 'email@example.com')
  puts "User registered successfully!"
  puts "User ID: #{user.id}"
rescue => e
  puts "Registration failed: #{e.message}"
end

# Login existing user
begin
  user = client.login('username', 'password')
  puts "User logged in successfully!"
  puts "Session ID: #{user.session_id}"
rescue => e
  puts "Login failed: #{e.message}"
end
```

### License Management

```ruby
# Validate a license
begin
  license = client.validate_license('LICENSE-KEY-HERE')
  puts "License is valid!"
  puts "License Key: #{license.key}"
  puts "Status: #{license.status}"
  puts "Expires: #{license.expires}"
  puts "Features: #{license.features.join(', ')}"
  puts "User: #{license.user}"
rescue => e
  puts "License validation failed: #{e.message}"
end

# Get user's licenses
begin
  licenses = client.get_user_licenses
  puts "Found #{licenses.length} licenses:"
  licenses.each_with_index do |license, index|
    puts "  #{index + 1}. #{license.key} - #{license.status} (Expires: #{license.expires})"
  end
rescue => e
  puts "Failed to get licenses: #{e.message}"
end
```

### Hardware ID Validation

```ruby
# Get hardware ID (automatically generated)
hardware_id = client.get_hardware_id
puts "Hardware ID: #{hardware_id}"

# Validate hardware ID with license
begin
  is_valid = client.validate_hardware_id('LICENSE-KEY-HERE', hardware_id)
  if is_valid
    puts "Hardware ID is valid for this license!"
  else
    puts "Hardware ID is not valid for this license."
  end
rescue => e
  puts "Hardware ID validation failed: #{e.message}"
end
```

### Webhook Integration

```ruby
# Set up webhook handler
client.set_webhook_handler do |event, data|
  puts "Webhook received: #{event}"
  
  case event
  when 'license.created'
    puts "New license created: #{data['licenseKey']}"
  when 'license.updated'
    puts "License updated: #{data['licenseKey']}"
  when 'license.revoked'
    puts "License revoked: #{data['licenseKey']}"
  end
end

# Start webhook listener
client.start_webhook_listener
```

## 📚 API Endpoints

Use the canonical API base URL `https://api.licensechain.app/v1`. The SDK also accepts the root host and normalizes requests to the same API version.

### Base URL
- **Production**: `https://api.licensechain.app/v1`
- **Development**: `https://api.licensechain.app/v1`

### Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/v1/health` | Health check |
| `POST` | `/v1/auth/login` | User login |
| `POST` | `/v1/auth/register` | User registration |
| `GET` | `/v1/apps` | List applications |
| `POST` | `/v1/apps` | Create application |
| `GET` | `/v1/licenses` | List licenses |
| `POST` | `/v1/licenses/verify` | Verify license |
| `GET` | `/v1/webhooks` | List webhooks |
| `POST` | `/v1/webhooks` | Create webhook |
| `GET` | `/v1/analytics` | Get analytics |

**Note**: The SDK accepts either the root host or the canonical `/v1` base and normalizes endpoint requests automatically.

## 📚 API Reference

### LicenseChain::Client

#### Constructor

```ruby
client = LicenseChain::Client.new(
  api_key: 'your-api-key',
  app_name: 'your-app-name',
  version: '1.0.0',
  base_url: 'https://api.licensechain.app/v1'  # Optional
)
```

#### Methods

##### Connection Management

```ruby
# Connect to LicenseChain
client.connect

# Disconnect from LicenseChain
client.disconnect

# Check connection status
is_connected = client.connected?
```

##### User Authentication

```ruby
# Register a new user
user = client.register(username, password, email)

# Login existing user
user = client.login(username, password)

# Logout current user
client.logout

# Get current user info
user = client.get_current_user
```

##### License Management

```ruby
# Validate a license
license = client.validate_license(license_key)

# Get user's licenses
licenses = client.get_user_licenses

# Create a new license
license = client.create_license(user_id, features, expires)

# Update a license
license = client.update_license(license_key, updates)

# Revoke a license
client.revoke_license(license_key)

# Extend a license
license = client.extend_license(license_key, days)
```

##### Hardware ID Management

```ruby
# Get hardware ID
hardware_id = client.get_hardware_id

# Validate hardware ID
is_valid = client.validate_hardware_id(license_key, hardware_id)

# Bind hardware ID to license
client.bind_hardware_id(license_key, hardware_id)
```

##### Webhook Management

```ruby
# Set webhook handler
client.set_webhook_handler(handler)

# Start webhook listener
client.start_webhook_listener

# Stop webhook listener
client.stop_webhook_listener
```

##### Analytics

```ruby
# Track event
client.track_event(event_name, properties)

# Get analytics data
analytics = client.get_analytics(time_range)
```

## 🔧 Configuration

### Environment Variables

Set these in your environment or through your build process:

```bash
# Required
export LICENSECHAIN_API_KEY=your-api-key
export LICENSECHAIN_APP_NAME=your-app-name
export LICENSECHAIN_APP_VERSION=1.0.0

# Optional
export LICENSECHAIN_BASE_URL=https://api.licensechain.app/v1
export LICENSECHAIN_DEBUG=true
```

### Advanced Configuration

```ruby
client = LicenseChain::Client.new(
  api_key: 'your-api-key',
  app_name: 'your-app-name',
  version: '1.0.0',
  base_url: 'https://api.licensechain.app/v1',
  timeout: 30,        # Request timeout in seconds
  retries: 3,         # Number of retry attempts
  debug: false,       # Enable debug logging
  user_agent: 'MyApp/1.0.0'  # Custom user agent
)
```

## 🛡️ Security Features

### Hardware ID Protection

The SDK automatically generates and manages hardware IDs to prevent license sharing:

```ruby
# Hardware ID is automatically generated and stored
hardware_id = client.get_hardware_id

# Validate against license
is_valid = client.validate_hardware_id(license_key, hardware_id)
```

### Secure Communication

- All API requests use HTTPS
- API keys are securely stored and transmitted
- Session tokens are automatically managed
- Webhook signatures are verified

### License Validation

- Real-time license validation
- Hardware ID binding
- Expiration checking
- Feature-based access control

## 📊 Analytics and Monitoring

### Event Tracking

```ruby
# Track custom events
client.track_event('app.started', {
  level: 1,
  playerCount: 10
})

# Track license events
client.track_event('license.validated', {
  licenseKey: 'LICENSE-KEY',
  features: 'premium,unlimited'
})
```

### Performance Monitoring

```ruby
# Get performance metrics
metrics = client.get_performance_metrics
puts "API Response Time: #{metrics.average_response_time}ms"
puts "Success Rate: #{(metrics.success_rate * 100).round(2)}%"
puts "Error Count: #{metrics.error_count}"
```

## 🔄 Error Handling

### Custom Exception Types

```ruby
begin
  license = client.validate_license('invalid-key')
rescue LicenseChain::InvalidLicenseError
  puts "License key is invalid"
rescue LicenseChain::ExpiredLicenseError
  puts "License has expired"
rescue LicenseChain::NetworkError => e
  puts "Network connection failed: #{e.message}"
rescue LicenseChain::LicenseChainError => e
  puts "LicenseChain error: #{e.message}"
end
```

### Retry Logic

```ruby
# Automatic retry for network errors
client = LicenseChain::Client.new(
  api_key: 'your-api-key',
  app_name: 'your-app-name',
  version: '1.0.0',
  retries: 3,        # Retry up to 3 times
  timeout: 30        # Wait 30 seconds for each request
)
```

## 🧪 Testing

### Unit Tests

```bash
# Run tests
rspec

# Run tests with coverage
rspec --format documentation

# Run specific test
rspec spec/client_spec.rb
```

### Integration Tests

```bash
# Test with real API
rspec spec/integration/
```

## License assertion JWT (RS256 + JWKS)

When Core API returns **`license_token`** and **`license_jwks_uri`**, verify offline with **`LicenseChain::LicenseAssertion.verify_license_assertion_jwt`** (`jwt` gem + JWKS fetch; claim **`token_use`** = **`licensechain_license_v1`**). A minimal **JWKS-only** CLI (no prior `verify` call in-process) is **[`examples/jwks_only.rb`](examples/jwks_only.rb)** — set **`LICENSECHAIN_LICENSE_TOKEN`** and **`LICENSECHAIN_LICENSE_JWKS_URI`** (optional **`LICENSECHAIN_EXPECTED_APP_ID`**), then `ruby examples/jwks_only.rb` (same env names as Go/Rust/PHP; [JWKS_EXAMPLE_PRIORITY](https://docs.licensechain.app/)).

## 📝 Examples

See the `examples/` directory for complete examples:

- `basic_usage.rb` - Basic SDK usage
- `advanced_features.rb` - Advanced features and configuration
- `webhook_integration.rb` - Webhook handling
- `jwks_only.rb` — RS256 `license_token` via JWKS only ([JWKS_EXAMPLE_PRIORITY](https://docs.licensechain.app/))

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Install Ruby 3.0 or later
3. Install dependencies: `bundle install`
4. Build: `gem build licensechain-sdk.gemspec`
5. Test: `rspec`

## 📄 License

This project is licensed under the Elastic License 2.0 (ELv2) — see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [https://docs.licensechain.app/ruby](https://docs.licensechain.app/ruby)
- **Issues**: [GitHub Issues](https://github.com/LicenseChain/LicenseChain-Ruby-SDK/issues)
- **Discord**: [LicenseChain Discord](https://discord.gg/licensechain)
- **Email**: support@licensechain.app

## 🔗 Related Projects

- [LicenseChain JavaScript SDK](https://github.com/LicenseChain/LicenseChain-JavaScript-SDK)
- [LicenseChain Python SDK](https://github.com/LicenseChain/LicenseChain-Python-SDK)
- [LicenseChain Node.js SDK](https://github.com/LicenseChain/LicenseChain-NodeJS-SDK)
---

**Made with ❤️ for the Ruby community**

## LicenseChain API (v1)

This SDK targets the **LicenseChain HTTP API v1** implemented by the LicenseChain API service.

- **Production base URL:** https://api.licensechain.app/v1
- **API reference:** [docs.licensechain.app](https://docs.licensechain.app/)
- **Baseline REST mapping (documented for integrators):**
  - GET /health
  - POST /auth/register
  - POST /licenses/verify
  - PATCH /licenses/:id/revoke
  - PATCH /licenses/:id/activate
  - PATCH /licenses/:id/extend
  - GET /analytics/stats

