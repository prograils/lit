require "bundler/gem_tasks"

APP_RAKEFILE = File.expand_path('../test/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Lit'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require "rake/testtask"
Rake::TestTask.new(:test) do |t|
  puts "Storage: #{ENV['LIT_STORAGE'] || 'redis'}"
  t.libs << 'test'
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test

