require 'rake/rdoctask'
require "rspec/core/rake_task" # RSpec 2.0

task :default => [:test]

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
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
task :spec => :test
