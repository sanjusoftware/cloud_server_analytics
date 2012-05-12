class Server < ActiveRecord::Base
  has_many :runs
  has_many :utilizations

  attr_accessible :name, :billing_owner

  def current_run
    runs.where(:state => Run::RUNNING).first
  end

end