require "spec_helper"

describe "Cloud Watch" do
  describe "update cost and utilization" do
    before(:each) do
      @cw = CloudServerAnalytics::CloudWatch.new

      response = {"xmlns" => "http://monitoring.amazonaws.com/doc/2009-05-15/",
                  "GetMetricStatisticsResult" => {
                      "Datapoints" =>
                          {"member" =>
                               [{"Timestamp" => "2012-05-13T14:23:00Z",
                                 "Unit" => "Percent", "Average" => "7.378", "Samples" => "5.0"},
                                {"Timestamp" => "2012-05-13T14:11:00Z", "Unit" => "Percent", "Average" => "7.409999999999999", "Samples" => "5.0"},
                                {"Timestamp" => "2012-05-13T14:35:00Z", "Unit" => "Percent", "Average" => "7.12", "Samples" => "5.0"},
                               ]
                          },
                      "Label" => "CPUUtilization"
                  },
                  "ResponseMetadata" => {"RequestId" => "234fbfb4-9d0d-11e1-a783-9d594f34f987"}}

      AWS::Cloudwatch::Base.any_instance.stubs(:get_metric_statistics).returns(response)
      run = mock("run")
      run.stubs(:add_hourly_cost)
      run.stubs(:save!)
      server = mock("server")
      server.stubs(:name).returns("i-7b0b0c18")
      server.stubs(:id).returns(1)
      run.stubs(:server).returns(server)
      Run.stubs(:where).returns([run])
      Utilization.stubs(:create!)
    end

    it "should print server list" do
      @cw.update_cost_and_utilization
    end
  end

end
