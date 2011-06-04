Gem::Specification.new do |s|
  s.author = 'Laurent Arnoud'
  s.email = 'laurent@spkdev.net'
  s.homepage = 'http://github.com/spk/validate-website'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Web crawler for checking the validity of your documents'
  s.name = 'validate-website'
  s.version = '0.6.1'
  s.license = 'MIT'
  s.requirements << 'anemone' << 'rainbow' << 'multipart_body'
  s.add_dependency('anemone', '>= 0.6.1')
  s.add_dependency('rainbow', '>= 1.1.1')
  s.add_dependency('multipart_body', '>= 0.2.1')
  s.add_development_dependency('rake', '>= 0.8.7')
  s.add_development_dependency('rspec', '>= 2.6.0')
  s.add_development_dependency('fakeweb', '>= 1.3.0')
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables << 'validate-website'
  s.executables << 'validate-website-static'
  s.files = Dir['README.rdoc', 'Rakefile', 'LICENSE',
    'bin',
    'lib/**/*.rb',
    'man/**/*',
    'data/**/*']
  s.description = %Q{validate-website is a web crawler for checking the markup \
validity with XML Schema / DTD and not found urls.}
  s.test_files = Dir.glob('spec/**/*')
end
