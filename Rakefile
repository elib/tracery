#!/usr/bin/env rake

require 'rake/testtask'
#require 'rubygems-tasks'

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['ruby/test/*.rb']
  t.verbose = true
end

#desc "Build gem"

task :default => :test