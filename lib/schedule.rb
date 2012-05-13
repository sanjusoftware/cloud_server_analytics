require 'resque'
require 'cloud_server_analytics'

Resque.enqueue(1.hour.from_now, CloudServerAnalytics::CloudWatch)