# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "authdog"
  spec.version       = "0.1.0"
  spec.authors       = ["Authdog"]
  spec.email         = ["dev@authdog.com"]

  spec.summary       = "Authdog Ruby SDK"
  spec.description   = "Minimal Ruby client for Authdog API"
  spec.homepage      = "https://github.com/authdog/authdog"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "json", ">= 2.0"

  spec.add_development_dependency "rspec", ">= 3.12"
  spec.add_development_dependency "webmock", ">= 3.18"
  spec.add_development_dependency "rake", ">= 13.0"
end
