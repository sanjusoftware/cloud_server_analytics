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

    def update_cost_and_utilization
      Database.establish_connection
      runs = Run.where(:state => "running").uniq
      runs.each do |run|
        run.add_hourly_cost
        save_metrics_for("CPUUtilization", run)
        save_metrics_for("NetworkIn", run)
        save_metrics_for("NetworkOut", run)
      end
    end

    private

    def save_metrics_for(measure, run)
      instance_id = run.server.name
      puts "Started getting #{measure} for instance #{instance_id}"
      metrics = CloudWatch.conn.get_metric_statistics(namespace: 'AWS/EC2',
                                                      measure_name: measure,
                                                      period: 360,
                                                      statistics: 'Average',
                                                      start_time: 1.hour.ago.to_time,
                                                      dimensions: "InstanceId=#{instance_id}")

      data_points = metrics['GetMetricStatisticsResult']['Datapoints']

      if data_points
        data_points['member'].each do |item|
          Utilization.create!(:server_id => run.server.id, :type => measure, :timestamp => item["Timestamp"],
                              :unit => item["Unit"], :average => item["Average"], :samples => item["Samples"])
        end
      end
      puts "Finished getting #{measure} for instance #{instance_id}"
    end
  end

end