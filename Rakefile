require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new 'rubocop' do |t|
  t.verbose = true
end

Rake::TestTask.new 'test' do |t|
  t.libs = %w(lib test)
  t.pattern = "test/*_test.rb"
  t.verbose = true
  t.warning = true
end

task default: :test
