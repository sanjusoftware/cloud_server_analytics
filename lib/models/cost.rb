class Cost < ActiveRecord::Base
  belongs_to :run

  attr_accessible :run_id, :amount, :upto
end