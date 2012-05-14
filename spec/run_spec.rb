require "spec_helper"

describe "Run" do
  before(:each) do
    server = Server.create!(:name => "server", :billing_owner => "sanjeev")
    @run = server.runs.create!(:id => 1, :state => Run::RUNNING, :start_time => Time.now - 1.hour, :region => "us-east-1", :flavor => "t1.micro")
  end

  describe "stop" do
    it "should stop the run and update the cost" do
      Cost.create!(:run_id => 1, :upto => Time.now)
      @run.costs.count.should == 1
      @run.stop
      @run.state.should == Run::STOPPED
      @run.costs.count.should == 2
    end
  end

  describe "is_same?" do
    it "should return true if they have same region state and flavor and they have same tags" do
      run1 = Run.new(:state => Run::RUNNING, :flavor => "flavor", :region => "region")
      run1.tags << Tag.new(:key => "key", :value => "value")
      run2 = Run.new(:state => Run::RUNNING, :flavor => "flavor", :region => "region")
      run2.tags << Tag.new(:key => "key", :value => "value")
      run1.is_same?(run2).should == true
    end
  end

  describe "add hourly cost" do
    it "should add if there is no previous cost record" do
      @run.costs.size.should == 0
      @run.add_hourly_cost
      @run.costs.size.should == 1
    end

    it "should not add cost if its not been more than one hour since the last recorded cost time" do
      @run.costs.create!(:upto => Time.now - 5.minutes)
      @run.costs.size.should == 1
      @run.add_hourly_cost
      @run.costs.size.should == 1
    end

    it "should add only if its been more than one hour since the last recorded cost time" do
      @run.costs.create!(:upto => Time.now - 2.hours)
      @run.costs.size.should == 1
      @run.add_hourly_cost
      @run.costs.size.should == 2
    end
  end

end