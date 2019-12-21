# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repp/heartful_slack/version'

Gem::Specification.new do |spec|
  spec.name          = 'repp-heartful_slack'
  spec.version       = Repp::HeartfulSlack::VERSION
  spec.authors       = ['ru_shalm']
  spec.email         = ['ru_shalm@hazimu.com']

  spec.summary       = 'repp-heartful_slack is a powerful handler of Repp for Slack.'
  spec.homepage      = 'https://github.com/rutan/repp-heartful_slack'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '0.78.0'
  spec.add_development_dependency 'test-unit', '~> 3.3'
end
