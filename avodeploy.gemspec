# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'avodeploy/version'

Gem::Specification.new do |spec|
  spec.name          = "avodeploy"
  spec.version       = Avocado::VERSION
  spec.authors       = ["David Prandzioch"]
  spec.email         = ["dprandzioch@me.com"]
  spec.summary       = %q{Avocado is a flexible deployment framework for web applications.}
  spec.description   = ""
  spec.homepage      = "http://dprandzioch.github.io/avocado/"
  spec.license       = "GPLv2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["avo"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "terminal-table", "~> 1.4.5"
  spec.add_dependency "net-ssh", "~> 2.9.1"
  spec.add_dependency "net-scp", "~> 1.2.1"
  spec.add_dependency "thor", "~> 0.19.1"
end
