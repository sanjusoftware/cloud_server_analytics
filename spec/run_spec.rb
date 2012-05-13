require "spec_helper"

describe "Run" do
  before(:each) do
    Database.establish_connection
  end

  describe "stop" do
    it "should stop the run and update the cost" do
      run = Run.new(:state => Run::RUNNING)
      run.expects(:costs).returns(nil)
      run.stop
      run.state.should == Run::STOPPED
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
      run = Run.new(:start_time => Time.now - 1.day, :flavor => "flavor", :region => "region")
      run.expects(:hourly_run_cost).returns(10)
      run.costs.size.should == 0
      run.add_hourly_cost
      run.costs.size.should == 1
    end

    it "should not add cost if its not been more than one hour since the last recorded cost time" do
      run = Run.new(:start_time => Time.now - 1.day, :flavor => "flavor", :region => "region")
      cost = Cost.new(:upto => Time.now - 5.minutes)
      costs = [cost]
      costs.expects(:order).returns(costs)
      costs.expects(:last).returns(cost)

      run.stubs(:costs).returns(costs)
      run.costs.size.should == 1
      run.add_hourly_cost
      run.costs.size.should == 1
    end

    it "should add only if its been more than one hour since the last recorded cost time" do
      run = Run.new(:start_time => Time.now - 1.day, :flavor => "flavor", :region => "region")
      cost = Cost.new(:upto => Time.now - 2.hours)
      costs = [cost]
      costs.expects(:order).returns(costs)
      costs.expects(:last).returns(cost)
      costs.expects(:new)
      run.stubs(:costs).returns(costs)
      run.expects(:hourly_run_cost).returns(10)
      run.add_hourly_cost
    end
  end

end