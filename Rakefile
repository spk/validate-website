# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'
require 'asciidoctor'

default = %i[test]
default << :rubocop unless RUBY_ENGINE == 'rbx'
task default: default

desc 'Update manpage from asciidoc file'
task :manpage do
  Dir.glob('doc/*.adoc').each do |adoc|
    Asciidoctor.convert_file adoc, to_file: true,
                                   backend: 'manpage',
                                   to_dir: 'man/man1'
  end
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
end
task spec: :test

desc 'Execute rubocop'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names', '--display-style-guide']
  t.fail_on_error = true
end
