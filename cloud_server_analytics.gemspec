# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','cloud_server_analytics.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'cloud_server_analytics'
  s.version = CloudServerAnalytics::VERSION
  s.author = 'Sanjeev Mishra'
  s.email = 'your@email.address.com'
  s.homepage = 'http://codemancers.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
# Add your other files here if you make them
  s.files = %w(
bin/cloud_server_analytics
lib/cloud_server_analytics.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','cloud_server_analytics.rdoc']
  s.rdoc_options << '--title' << 'cloud_server_analytics' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'cloud_server_analytics'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_runtime_dependency('gli')
end
