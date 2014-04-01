# encoding: utf-8
begin
  require 'bundler'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.libs.push "spec"
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
end

task :default => ['test']
