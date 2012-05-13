class Server < ActiveRecord::Base
  has_many :runs
  has_many :utilizations

  attr_accessible :name, :billing_owner

  def current_run
    runs.where(:state => Run::RUNNING).first
  end

  # If CPU utilization is less than one percent in last 1 hrs, then we are going to consider the server
  # to be idle
  def is_idle?
    end_time = Time.now
    start_time = end_time - 1.hour
    server_utilizations = self.utilizations.where(:timestamp => start_time..end_time, :type => "CPUUtilization")
    (server_utilizations.sum(:average) / server_utilizations.count) < 1
  end

end