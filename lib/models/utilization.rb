class Utilization < ActiveRecord::Base
  belongs_to :server

  attr_accessible :server_id, :type, :timestamp, :unit, :average, :samples
end