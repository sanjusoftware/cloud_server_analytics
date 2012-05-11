require "active_record"
class Tag < ActiveRecord::Base
  attr_accessible :instance_id, :key, :value

end