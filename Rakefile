require 'rake/clean'
require 'rake/testtask'

desc "Run tests"
Rake::TestTask.new("test") do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = false
end

