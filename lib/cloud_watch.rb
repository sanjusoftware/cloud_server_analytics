module CloudServerAnalytics
  class CloudWatch

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

    def load_utilization_metrics
      Database.establish_connection
      ids = Run.select(:instance_id).uniq
      ids.each do |run|
        save_metrics_for("CPUUtilization", run.instance_id)
        save_metrics_for("NetworkIn", run.instance_id)
        save_metrics_for("NetworkOut", run.instance_id)
      end
    end

    def save_metrics_for(measure, instance_id)
      metrics = CloudWatch.conn.get_metric_statistics(namespace: 'AWS/EC2',
                                                      measure_name: measure,
                                                      statistics: 'Average',
                                                      start_time: 1.hour.ago.to_time,
                                                      dimensions: "InstanceId=#{instance_id}")

      data_points = metrics['GetMetricStatisticsResult']['Datapoints']

      if data_points
        data_points['member'].each do |item|
          Utilization.create!(:instance_id => instance_id, :type => measure, :timestamp => item["Timestamp"],
                              :unit => item["Unit"], :average => item["Average"], :samples => item["Samples"])
        end
      end
    end
  end

end