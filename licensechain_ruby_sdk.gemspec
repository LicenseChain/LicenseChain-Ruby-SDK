# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "licensechain_ruby_sdk"
  spec.version       = "1.0.0"
  spec.authors       = ["LicenseChain Team"]
  spec.email         = ["support@licensechain.app"]

  spec.summary       = "Official LicenseChain Ruby SDK for license management and validation"
  spec.description   = "A comprehensive Ruby SDK for integrating with LicenseChain's license management platform. Provides full API access for license validation, user management, application management, and more."
  spec.homepage      = "https://github.com/LicenseChain/LicenseChain-Ruby-SDK"
  spec.license = "Elastic-2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/LicenseChain/LicenseChain-Ruby-SDK"
  spec.metadata["changelog_uri"] = "https://github.com/LicenseChain/LicenseChain-Ruby-SDK/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://docs.licensechain.app/sdks/ruby"
  spec.metadata["bug_tracker_uri"] = "https://github.com/LicenseChain/LicenseChain-Ruby-SDK/issues"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_dependency "faraday", "~> 2.7"
  spec.add_dependency "faraday-retry", "~> 2.2"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "jwt", "~> 2.8"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rspec", "~> 2.20"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "yard", "~> 0.9"
end
