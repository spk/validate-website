Gem::Specification.new do |s|
  s.author = 'Laurent Arnoud'
  s.email = 'laurent@spkdev.net'
  s.homepage = 'http://github.com/spk/validate-website'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Web crawler for checking the validity of your documents'
  s.name = 'validate-website'
  s.version = '0.8.1'
  s.license = 'MIT'
  s.requirements << 'spidr' << 'rainbow' << 'multipart_body'
  s.add_dependency('spidr', '~> 0.4')
  s.add_dependency('paint', '~> 0.8')
  s.add_dependency('multipart_body', '~> 0.2')
  s.add_development_dependency('rake', '~> 10.3')
  s.add_development_dependency('minitest', '~> 5.4')
  s.add_development_dependency('webmock', '~> 1.18')
  s.add_development_dependency('pry', '~> 0.9')
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables << 'validate-website'
  s.executables << 'validate-website-static'
  s.files = Dir['README.rdoc', 'Rakefile', 'LICENSE',
    'bin',
    'lib/**/*.rb',
    'man/**/*',
    'spec/**/*',
    'data/**/*']
  s.description = %Q{validate-website is a web crawler for checking the markup \
validity with XML Schema / DTD and not found urls.}
  s.test_files = Dir.glob('spec/**/*_spec.rb')
end
