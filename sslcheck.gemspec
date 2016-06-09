# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sslcheck/version'

Gem::Specification.new do |spec|
  spec.name          = "sslcheck"
  spec.version       = SSLCheck::VERSION
  spec.authors       = ["Clayton Lengel-Zigich"]
  spec.email         = ["clayton@claytonlz.com"]
  spec.summary       = %q{Discover errors with SSL certificates.}
  spec.description   = %q{A simple ruby library to help verify the installation of SSL certificates.}
  spec.homepage      = "http://github.com/clayton/sslcheck"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 4.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "blinky-tape-test-status", "~> 1.1"
  spec.add_development_dependency "simplecov", "~> 0.9"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.5"
end
