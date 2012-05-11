require "active_record"
class Run < ActiveRecord::Base
  attr_accessible :instance_id, :start_time, :stop_time, :ec2_region, :state, :flavor

  VALID_STATES = %w(running stopped terminated)
  RUNNING = 'running'
  STOPPED = 'stopped'
  TERMINATED = 'terminated'

end