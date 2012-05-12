module CloudServerAnalytics
  class CloudWatch

    require 'aws'

    @@conn = nil

    def self.conn
      if @@conn
        @@conn
      else
        aws_config = YAML.load_file(File.join(File.dirname(__FILE__), "../config/secret_key.yml"))
        @@conn = AWS::Cloudwatch::Base.new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
        @@conn
      end
    end

    def get_metrics
      Database.establish_connection
      ids = Run.select(:instance_id)
      ids.each do |run|
        puts "going for #{run.instance_id}"
        metrics = CloudWatch.conn.get_metric_statistics(namespace: 'AWS/EC2',
                                                        measure_name: 'CPUUtilization',
                                                        statistics: 'Average',
                                                        start_time: 1.hour.ago.to_time,
                                                        dimensions: "InstanceId=#{run.instance_id}")

        datapoints = metrics['GetMetricStatisticsResult']['Datapoints']

        if datapoints
          datapoints['member'].each do |item|
            puts item
          end
        end
      end
    end
  end

end