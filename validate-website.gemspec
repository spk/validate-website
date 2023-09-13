# frozen_string_literal: true

require File.expand_path('lib/validate_website/version', __dir__)

Gem::Specification.new do |s|
  s.author = 'Laurent Arnoud'
  s.email = 'laurent@spkdev.net'
  s.homepage = 'http://github.com/spk/validate-website'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Web crawler for checking the validity of your documents'
  s.name = 'validate-website'
  s.version = ValidateWebsite::VERSION
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.7'
  s.add_dependency 'crass', '~> 1'
  s.add_dependency 'nokogiri', '~> 1.15'
  s.add_dependency 'paint', '~> 2'
  s.add_dependency 'slop', '~> 4.6'
  s.add_dependency 'spidr', '~> 0.7'
  s.add_dependency 'tidy_ffi', '~> 1.0'
  s.add_dependency 'w3c_validators', '~> 1.3'
  s.add_dependency 'webrick', '~> 1'
  s.add_development_dependency 'asciidoctor', '~> 1.5'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake', '~> 12'
  s.add_development_dependency 'rubocop', '~> 0.76.0'
  s.add_development_dependency 'webmock', '~> 3.4'
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables << 'validate-website'
  s.executables << 'validate-website-static'
  s.files = Dir['README.md', 'Rakefile', 'LICENSE', 'History.md',
                'bin',
                'lib/**/*.rb',
                'man/**/*',
                'test/**/*',
                'data/**/*']
  s.description = %(validate-website is a web crawler for checking the markup \
validity with XML Schema / DTD and not found urls.)
  s.test_files = Dir.glob('test/**/*_test.rb')
end
