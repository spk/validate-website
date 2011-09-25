require 'rdoc/task'
require 'rake/testtask'

task :default => [:test]

RDoc::Task.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

desc 'Update manpage from asciidoc file'
task :manpage do
  system('find doc/ -type f -exec a2x -f manpage -D man/man1 {} \;')
end

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end
task :spec => :test
