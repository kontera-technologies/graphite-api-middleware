lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphite-api/middleware/version"

Gem::Specification.new do |spec|
  spec.name          = "graphite-api-middleware"
  spec.version       = GraphiteAPI::Middleware::VERSION
  spec.authors       = ["Eran Levi", "Eyal Shalev"]
  spec.email         = ["eran@kontera.com", "eyalsh@gmail.com"]

  spec.summary       = %q{Aggregator daemon for Graphite API}
  spec.description   = %q{Interact with Graphite's Carbon Daemon through this middleware}
  spec.homepage      = "https://github.com/kontera-technologies/graphite-api-middleware"
  spec.license       = 'LGPL-3.0'

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.files         = %w(LICENSE.txt README.md Rakefile) + Dir.glob("{bin,lib,test,tasks}/**/*")

  spec.required_ruby_version = '>= 2.2'
  spec.add_runtime_dependency 'eventmachine','>= 0.3.3'
  spec.add_runtime_dependency 'graphite-api', '>= 0.4.0'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "codecov", "~> 0.1"
  spec.add_development_dependency "simplecov-rcov", "~> 0.2"
  spec.add_development_dependency "gem-release", "~> 2.0"
end
