require "active_record"
class Utilization < ActiveRecord::Base
  attr_accessible :instance_id, :type, :timestamp, :unit, :average, :samples
end