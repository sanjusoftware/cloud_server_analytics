module CloudServerAnalytics
  class CloudWatch < API

    attr_accessor :queue

    @queue = :cost_and_utilization

    def conn_obj
      "AWS::Cloudwatch::Base"
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
      metrics = conn.get_metric_statistics(namespace: 'AWS/EC2',
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