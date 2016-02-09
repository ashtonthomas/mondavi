# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mondavi/version'

Gem::Specification.new do |spec|
  spec.name          = "mondavi"
  spec.version       = Mondavi::VERSION
  spec.authors       = ["Ashton Thomas"]
  spec.email         = ["athomas@bellycard.com"]

  spec.summary       = %q{A framework for the structure of and communication between napa-based, internal microservices.}
  spec.description   = %q{Strucutre internal microservies for efficient use of developer resources and infrastructure cost. Communicate in a more robust HATEOS-like manner. }
  spec.homepage      = "https://github.com/ashtonthomas/mondavi"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # spec.add_dependency 'napa'
  spec.add_dependency 'tannin'

  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'hashie'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'celluloid', '>= 0.17.0'
  spec.add_dependency 'celluloid-io'
  spec.add_dependency 'imprint'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'pry'
end
