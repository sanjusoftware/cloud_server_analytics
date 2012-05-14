require "spec_helper"

describe "Cloud Watch" do
  describe "update cost and utilization" do
    it "should print server list" do
      @cw = CloudServerAnalytics::CloudWatch.new

      response = {"xmlns" => "http://monitoring.amazonaws.com/doc/2009-05-15/",
                  "GetMetricStatisticsResult" =>
                    {
                      "Datapoints" =>
                        {"member" =>
                           [
                             {"Timestamp" => "2012-05-13T14:23:00Z", "Unit" => "Percent", "Average" => "7.378", "Samples" => "5.0"},
                             {"Timestamp" => "2012-05-13T14:11:00Z", "Unit" => "Percent", "Average" => "7.409999999999999", "Samples" => "5.0"},
                             {"Timestamp" => "2012-05-13T14:35:00Z", "Unit" => "Percent", "Average" => "7.12", "Samples" => "5.0"}
                           ]
                        },
                      "Label" => "CPUUtilization"
                    },
                  "ResponseMetadata" => {"RequestId" => "234fbfb4-9d0d-11e1-a783-9d594f34f987"}}

      AWS::Cloudwatch::Base.any_instance.stubs(:get_metric_statistics).returns(response)
      Server.create!(:id => 1, :name => "i-7b0b0c18")
      Run.create!(:state => "running", :start_time => Time.now - 1.hour, :server_id => 1)
      Run.any_instance.expects(:add_hourly_cost)
      Utilization.count.should == 0
      @cw.update_cost_and_utilization
      Utilization.count.should == 9
    end
  end

end
