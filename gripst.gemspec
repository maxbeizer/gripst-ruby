# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gripst/version'

Gem::Specification.new do |spec|
  spec.name          = 'gripst'
  spec.version       = Gripst::VERSION
  spec.authors       = ['Max Beizer']
  spec.email         = ['max.beizer@gmail.com']
  spec.description   = %q{Brute-force grep your gists}
  spec.summary       = %q{Brute-force grep your gists for when the search tool is not enough}
  spec.homepage      = 'https://github.com/maxbeizer/gripst'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0'

  spec.add_runtime_dependency 'octokit', '~> 3.3', '>= 3.3.1'
  spec.add_runtime_dependency 'git', '~> 1.2', '>= 1.2.8'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 0'
  spec.add_development_dependency 'pry', '~> 0'
end
