require "spec_helper"

describe "Server" do
  before(:each) do
    @server = Server.new(:name => "i-7b0b0c18", :billing_owner => "sanjeev")
  end

  describe "is_idle?" do
    it "should be treated as idle in case the CPU Utilization is below 1 percent for the last 1 hour" do
      @server.utilizations.new(:type => "CPUUtilization", :timestamp => Time.now - 15.minutes, :average => 0.02)
      @server.utilizations.new(:type => "CPUUtilization", :timestamp => Time.now - 30.minutes, :average => 0.06)
      @server.save!
      @server.is_idle?.should be true
    end
  end

  describe "current run" do
    it "should return the server run which is in running state" do
      @server = Server.new(:id => 1)
      @server.runs.new(:state => 'running', :flavor => "test_flavor")
      @server.runs.new(:state => 'stopped', :flavor => "test_flavor")
      @server.save!
      @server.current_run.flavor.should == "test_flavor"
    end
  end
end