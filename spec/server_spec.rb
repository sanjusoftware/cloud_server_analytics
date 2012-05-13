require "spec_helper"

describe "Server" do

  it "should be treated as idle in case the CPU Utilization is below 1 percent for the last 1 hour" do
    Database.establish_connection
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