require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake'
require 'find'
require "rspec/core/rake_task" # RSpec 2.0

# Globals

PKG_NAME = 'validate-website'
PKG_VERSION = '0.5.2'

PKG_FILES = ['README.rdoc', 'Rakefile', 'LICENSE']
Find.find('bin/', 'lib/', 'man/', 'spec/') do |f|
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
  s.requirements << 'spk-anemone' << 'rainbow' << 'spk-html5'
  s.add_dependency('spk-anemone', '>= 0.4.0')
  s.add_dependency('rainbow', '>= 1.1')
  s.add_dependency('spk-html5', '= 0.10.1')
  s.add_development_dependency('rspec', '>= 2.0.0')
  s.add_development_dependency('fakeweb', '>= 1.3.0')
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables << 'validate-website'
  s.files = PKG_FILES
  s.description = 'validate-website is a web crawler for checking the markup' +
    'validity and not found urls.'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc 'Update manpage from asciidoc file'
task :manpage do
  system('a2x -f manpage -D man/man1 doc/validate-website.txt')
end

# RSpec 2.0
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end
