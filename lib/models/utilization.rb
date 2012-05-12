class Utilization < ActiveRecord::Base
  attr_accessible :server_id, :type, :timestamp, :unit, :average, :samples
end