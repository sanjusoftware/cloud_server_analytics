require "spec_helper"

describe "EC2" do
  before(:each) do
    @ec2 = CloudServerAnalytics::EC2.new
  end

  describe "load instances" do
    it "should print server list" do
      response = {"xmlns" => "http://ec2.amazonaws.com/doc/2010-08-31/", "requestId" => "9538620b-7a5f-4b05-8184-a52804b43cac",
                  "reservationSet" =>
                    {"item" => [
                      {"instancesSet" =>
                         {"item" =>
                            [
                              {"instanceId" => "test_instance",
                               "instanceState" => {"code" => "80", "name" => "stopped"},
                               "reason" => "User initiated (2011-12-31 17:26:45 GMT)",
                               "instanceType" => "t1.micro",
                               "launchTime" => "2011-12-05T18:14:42.000Z",
                               "placement" => {"availabilityZone" => "us-east-1a", "groupName" => nil},
                               "monitoring" => {"state" => "disabled"},
                               "stateReason" => {"code" => "Client.UserInitiatedShutdown", "message" => "Client.UserInitiatedShutdown: User initiated shutdown"},
                               "tagSet" =>
                                 {"item" =>
                                    [
                                      {"key" => "inscitiv:task-message", "value" => "Bootstrapped core packages"},
                                      {"key" => "inscitiv:task-name", "value" => "corePackages"},
                                      {"key" => "inscitiv:organization", "value" => "inscitiv_dev"},
                                      {"key" => "inscitiv:status", "value" => "running"},
                                      {"key" => "inscitiv:task-error-code", "value" => nil},
                                      {"key" => "inscitiv:owner", "value" => "kgilpin"},
                                      {"key" => "Name", "value" => "Workspace DB Server"}
                                    ]
                                 }
                              }
                            ]}
                      }
                    ]
                    }
      }
      AWS::EC2::Base.any_instance.expects(:describe_instances).returns(response)

      Server.find_by_name('test_instance').should be nil
      @ec2.load_instances
      Server.find_by_name('test_instance').should_not be nil
    end
  end

  describe "stop instance" do
    it "should raise error if the server name is not found" do
      lambda {
        @ec2.stop_server("not_existing_server")
      }.should raise_error
    end

    it "should raise error if the server name is not found" do
      server = mock("server")
      AWS::EC2::Base.any_instance.expects(:stop_instances)
      run = mock("run")
      run.expects(:stop)
      server.expects(:current_run).returns(run)
      Server.expects(:find_by_name).returns(server)
      lambda {
        @ec2.stop_server("not_existing_server")
      }.should_not raise_error
    end
  end

end
