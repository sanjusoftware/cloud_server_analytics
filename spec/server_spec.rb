require "spec_helper"

describe "Server" do
  before(:each) do
    Database.establish_connection
  end

  describe "is_idle?" do
    it "should be treated as idle in case the CPU Utilization is below 1 percent for the last 1 hour" do
      server = Server.new(:name => "i-7b0b0c18", :billing_owner => "sanjeev")
      utilization1 = Utilization.new(:type => "CPUUtilization", :timestamp => Time.now - 15.minutes, :average => 0.02)
      utilization2 = Utilization.new(:type => "CPUUtilization", :timestamp => Time.now - 30.minutes, :average => 0.06)
      utilizations = [utilization1, utilization2]
      utilizations.expects(:where).returns(utilizations)
      utilizations.expects(:sum).returns(0.08)
      server.expects(:utilizations).returns(utilizations)
      server.is_idle?.should be true
    end
  end

  describe "current run" do
    it "should return the server run which is in running state" do
      server = Server.new(:id => 1)
      run1 = Run.new(:server_id => 1, :state => 'running', :flavor => "test_flavor")
      run2 = Run.new(:server_id => 1, :state => 'stopped', :flavor => "test_flavor")
      runs = [run1, run2]
      runs.expects(:where).returns(run1)
      run1.expects(:first).returns(run1)
      server.expects(:runs).returns(runs)
      server.current_run.flavor.should == "test_flavor"
    end
  end
end