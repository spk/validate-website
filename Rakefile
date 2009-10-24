require 'rake/testtask'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake'
require 'find'

# Globals

PKG_NAME = 'validate-website'
PKG_VERSION = '0.1'

PKG_FILES = ['README', 'Rakefile']
Find.find('lib/', 'bin/') do |f|
  if FileTest.directory?(f) and f =~ /\.svn|\.git/
    Find.prune
  else
    PKG_FILES << f
  end
end

# Tasks

task :default => [:clean, :repackage]

#Rake::TestTask.new do |t|
  #t.libs << "test"
  #t.test_files = FileList['test/tc_*.rb']
#end

Rake::RDocTask.new do |rd|
  f = []
  require 'find'
  Find.find('lib/') do |file|
    # Skip hidden files (.svn/ directories and Vim swapfiles)
    if file.split(/\//).last =~ /^\./
      Find.prune
    else
      f << file if not FileTest.directory?(file)
    end
  end
  rd.rdoc_files.include(f)
  rd.options << '--all'
end

Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |p|
  p.need_tar = true
  p.package_files = PKG_FILES
end

# "Gem" part of the Rakefile
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.author = 'spk'
  s.email = 'spk@tuxfamily.org'
  s.platform = Gem::Platform::RUBY
  s.summary = "Web crawler for testing webpage validity"
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.requirements << 'libxml-ruby'
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables << 'validate-website'
  s.files = PKG_FILES
  s.description = "Web crawler that print if the page is valid with the dtd"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
