
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphite-api/middleware/version"

Gem::Specification.new do |spec|
  spec.name          = "graphite-api-middleware"
  spec.version       = GraphiteAPI::Middleware::VERSION
  spec.authors       = ["Eran Levi", "Eyal Shalev"]
  spec.email         = ["eran@kontera.com", "eyalsh@gmail.com"]

  spec.summary       = %q{Interact with Graphite's Carbon Daemon through this middleware}
  spec.homepage      = "https://github.com/kontera-technologies/graphite-api-middleware"
  spec.license       = 'LGPL-3.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'graphite-api', '>= 0.4.0'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "gem-release", "~> 2.0"
end
