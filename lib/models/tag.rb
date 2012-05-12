class Tag < ActiveRecord::Base
  belongs_to :run

  attr_accessible :run_id, :key, :value

  def is_same?(other)
    self.key == other.key && self.value == other.value
  end

end