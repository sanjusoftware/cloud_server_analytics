require 'ec2'
require 'cloud_watch'
require 'aws'
require 'active_record'
require 'models/run'
require 'models/cost'
require 'models/server'
require 'models/utilization'
require 'models/tag'
require 'database'
require 'time'
require 'pry'

module CloudServerAnalytics
  VERSION = '0.0.1'
end

CSA = CloudServerAnalytics
