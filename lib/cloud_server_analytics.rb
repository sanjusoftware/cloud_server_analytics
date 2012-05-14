require_relative 'api'
require_relative 'ec2'
require_relative 'cloud_watch'
require 'aws'
require 'active_record'
require_relative 'models/run'
require_relative 'models/cost'
require_relative 'models/server'
require_relative 'models/utilization'
require_relative 'models/tag'
require_relative 'database'
require 'time'
require 'pry'

module CloudServerAnalytics
  VERSION = '0.0.1'
end

CSA = CloudServerAnalytics
