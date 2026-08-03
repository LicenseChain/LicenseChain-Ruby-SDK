#!/usr/bin/env ruby

require_relative '../lib/licensechain_ruby_sdk'

# Configure the SDK
LicenseChainRubySdk.configure do |config|
  config.api_key = 'your-api-key-here'
  config.base_url = 'https://api.licensechain.app/v1'
  config.timeout = 30
  config.retries = 3
end

# Initialize the client
client = LicenseChainRubySdk.client

puts "🚀 LicenseChain Ruby SDK - Basic Usage Example\n"

begin
  # 1. License Management
  puts "🔑 License Management:"
  
  # Create a license
  metadata = {
    'platform' => 'ruby',
    'version' => '1.0.0',
    'features' => ['validation', 'webhooks']
  }
  
  license = client.licenses.create('user123', 'product456', metadata)
  puts "✅ License created: #{license.id}"
  puts "   License Key: #{license.license_key}"
  puts "   Status: #{license.status}"
  
  # Validate a license
  license_key = LicenseChain::Utils.generate_license_key
  puts "\n🔍 Validating license key: #{license_key}"
  
  is_valid = client.licenses.validate(license_key)
  if is_valid
    puts "✅ License is valid"
  else
    puts "❌ License is invalid"
  end
  
  # Get license stats
  stats = client.licenses.stats
  puts "\n📊 License Statistics:"
  puts "   Total: #{stats.total}"
  puts "   Active: #{stats.active}"
  puts "   Expired: #{stats.expired}"
  puts "   Revenue: $#{stats.revenue}"
  
  # 2. User Management
  puts "\n👤 User Management:"
  
  # Create a user
  user_metadata = {
    'source' => 'ruby-sdk',
    'plan' => 'premium'
  }
  
  user = client.users.create('user@example.com', 'John Doe', user_metadata)
  puts "✅ User created: #{user.id}"
  puts "   Email: #{user.email}"
  puts "   Name: #{user.name}"
  
  # Get user stats
  user_stats = client.users.stats
  puts "\n📊 User Statistics:"
  puts "   Total: #{user_stats.total}"
  puts "   Active: #{user_stats.active}"
  puts "   Inactive: #{user_stats.inactive}"
  
  # 3. Product Management
  puts "\n📦 Product Management:"
  
  # Create a product
  product_metadata = {
    'category' => 'software',
    'tags' => ['premium', 'enterprise']
  }
  
  product = client.products.create(
    'My Software Product',
    'A great software product',
    99.99,
    'USD',
    product_metadata
  )
  puts "✅ Product created: #{product.id}"
  puts "   Name: #{product.name}"
  puts "   Price: $#{product.price} #{product.currency}"
  
  # Get product stats
  product_stats = client.products.stats
  puts "\n📊 Product Statistics:"
  puts "   Total: #{product_stats.total}"
  puts "   Active: #{product_stats.active}"
  puts "   Revenue: $#{product_stats.revenue}"
  
  # 4. Webhook Management
  puts "\n🔗 Webhook Management:"
  
  # Create a webhook
  events = [
    LicenseChain::WebhookEvents::LICENSE_CREATED,
    LicenseChain::WebhookEvents::LICENSE_UPDATED,
    LicenseChain::WebhookEvents::USER_CREATED
  ]
  
  webhook = client.webhooks.create('https://example.com/webhook', events, 'webhook-secret')
  puts "✅ Webhook created: #{webhook.id}"
  puts "   URL: #{webhook.url}"
  puts "   Events: #{webhook.events.join(', ')}"
  
  # 5. Webhook Processing
  puts "\n🔄 Webhook Processing:"
  
  webhook_handler = LicenseChain::WebhookHandler.new('webhook-secret')
  
  # Simulate a webhook event
  webhook_event = {
    id: 'evt_123',
    type: LicenseChain::WebhookEvents::LICENSE_CREATED,
    data: {
      id: 'lic_123',
      user_id: 'user_123',
      product_id: 'prod_123',
      license_key: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345',
      status: 'active',
      created_at: '2023-01-01T00:00:00Z'
    },
    timestamp: '2023-01-01T00:00:00Z',
    signature: 'signature_here'
  }
  
  webhook_handler.process_event(webhook_event)
  puts "✅ Webhook event processed successfully"
  
  # 6. Utility Functions
  puts "\n🛠️ Utility Functions:"
  
  # Email validation
  email = 'test@example.com'
  puts "Email '#{email}' is valid: #{LicenseChain::Utils.validate_email(email)}"
  
  # License key validation
  license_key = LicenseChain::Utils.generate_license_key
  puts "License key '#{license_key}' is valid: #{LicenseChain::Utils.validate_license_key(license_key)}"
  
  # Generate UUID
  uuid = LicenseChain::Utils.generate_uuid
  puts "Generated UUID: #{uuid}"
  
  # Format bytes
  bytes = 1024 * 1024
  puts "#{bytes} bytes = #{LicenseChain::Utils.format_bytes(bytes)}"
  
  # Format duration
  seconds = 3661
  puts "Duration: #{LicenseChain::Utils.format_duration(seconds)}"
  
  # String utilities
  text = 'Hello World'
  puts "Capitalize first: #{LicenseChain::Utils.capitalize_first(text)}"
  puts "To snake_case: #{LicenseChain::Utils.to_snake_case('HelloWorld')}"
  puts "To PascalCase: #{LicenseChain::Utils.to_pascal_case('hello_world')}"
  puts "Slugify: #{LicenseChain::Utils.slugify('Hello World!')}"
  
  # 7. Error Handling
  puts "\n🛡️ Error Handling:"
  
  begin
    client.licenses.get('invalid-id')
  rescue LicenseChain::ValidationError => e
    puts "✅ Caught expected validation error: #{e.message}"
  end
  
  begin
    client.users.create('invalid-email', 'John Doe')
  rescue LicenseChain::ValidationError => e
    puts "✅ Caught expected validation error: #{e.message}"
  end
  
  puts "\n✅ Basic usage example completed successfully!"
  
rescue => e
  puts "❌ Error: #{e.class} - #{e.message}"
  puts e.backtrace if ENV['DEBUG']
end
