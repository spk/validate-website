require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake'
require 'find'
require "rspec/core/rake_task" # RSpec 2.0

# Globals

PKG_NAME = 'validate-website'
PKG_VERSION = '0.6.0'

PKG_FILES = ['README.rdoc', 'Rakefile', 'LICENSE']
Find.find('bin/', 'lib/', 'man/', 'spec/', 'data/') do |f|
  if FileTest.directory?(f) and f =~ /\.svn|\.git/
    Find.prune
  else
    PKG_FILES << f
  end
end

# Tasks

task :default => [:clean, :repackage]

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |p|
  p.need_tar = true
  p.package_files = PKG_FILES
end

# "Gem" part of the Rakefile
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.author = 'Laurent Arnoud'
  s.email = 'laurent@spkdev.net'
  s.homepage = 'http://github.com/spk/validate-website'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Web crawler for checking the validity of your documents'
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.license = 'MIT'
  s.requirements << 'anemone' << 'rainbow'
  s.add_dependency('anemone', '>= 0.5.0')
  s.add_dependency('rainbow', '>= 1.1')
  s.add_development_dependency('rspec', '>= 2.0.0')
  s.add_development_dependency('fakeweb', '>= 1.3.0')
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables << 'validate-website'
  s.executables << 'validate-website-static'
  s.files = PKG_FILES
  s.description = 'validate-website is a web crawler for checking the markup' +
    'validity and not found urls.'
  s.test_files = Dir.glob('spec/*_spec.rb')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc 'Update manpage from asciidoc file'
task :manpage do
  system('find doc/ -type f -exec a2x -f manpage -D man/man1 {} \;')
end

# RSpec 2.0
RSpec::Core::RakeTask.new(:test) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end
