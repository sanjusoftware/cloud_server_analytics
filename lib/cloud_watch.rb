module CloudServerAnalytics
  class CloudWatch

    attr_accessor :queue

    @@conn = nil
    @queue = :cost_and_utilization

    def self.conn
      if @@conn
        @@conn
      else
        aws_config = YAML.load_file(File.join(File.dirname(__FILE__), "../config/secret_key.yml"))
        @@conn = AWS::Cloudwatch::Base.new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
        @@conn
      end
    end

    def perform
      puts "came to perform the job"
      update_cost_and_utilization
    end

    def update_cost_and_utilization
      runs = Run.where(:state => "running").uniq
      runs.each do |run|
        run.add_hourly_cost
        save_metrics_for("CPUUtilization", run)
        save_metrics_for("NetworkIn", run)
        save_metrics_for("NetworkOut", run)
        run.save!
      end
    end

    private

    def save_metrics_for(measure, run)
      instance_id = run.server.name
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
    end
  end

end