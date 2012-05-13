require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
#require 'resque/tasks'
#require 'resque_scheduler/tasks'
#
#$: << File.expand_path(File.dirname(File.realpath(__FILE__)) + './../lib')
#require 'cloud_server_analytics'
#
#namespace :resque do
#  task :setup do
#    require 'resque'
#    require 'resque_scheduler'
#    require 'resque/scheduler'
#
#    # you probably already have this somewhere
#    Resque.redis = 'localhost:5678'
#
#    # The schedule doesn't need to be stored in a YAML, it just needs to
#    # be a hash.  YAML is usually the easiest.
#    Resque.schedule = YAML.load_file('./config/resque_schedule.yml')
#
#    # If your schedule already has +queue+ set for each job, you don't
#    # need to require your jobs.  This can be an advantage since it's
#    # less code that resque-scheduler needs to know about. But in a small
#    # project, it's usually easier to just include you job classes here.
#    # So, someting like this:
#    require 'jobs'
#  end
#end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb", "bin/**/*")
  rd.title = 'Your application title'
end

spec = eval(File.read('cloud_server_analytics.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/tc_*.rb']
end

task :default => :test
