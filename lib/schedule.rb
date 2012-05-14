require_relative 'resque'
require_relative 'cloud_server_analytics'

Resque.enqueue(1.hour.from_now, CloudServerAnalytics::CloudWatch)