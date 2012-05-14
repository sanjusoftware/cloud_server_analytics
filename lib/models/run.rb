class Run < ActiveRecord::Base
  belongs_to :server
  has_many :tags
  has_many :costs

  attr_accessible :server_id, :start_time, :stop_time, :region, :state, :flavor

  VALID_STATES = %w(running stopped terminated)
  RUNNING = 'running'
  STOPPED = 'stopped'
  TERMINATED = 'terminated'
  AN_HOUR = 3600

  def stop
    self.state = STOPPED
    self.stop_time = Time.now
    if costs
      add_cost(costs.order("upto desc").last().upto, self.stop_time)
    end
  end

  def is_same?(other)
    self.region == other.region &&
        self.state == other.state &&
        self.flavor == other.flavor &&
        all_tags_are_same(other)
  end

  def add_hourly_cost
    if costs.present?
      last_upto = costs.order("upto desc").last().upto
      if has_one_hour_passed?(last_upto)
        costs.create!(:amount => hourly_run_cost, :upto => last_upto + AN_HOUR, :billing_owner => server.billing_owner)
      end
    else
      add_cost(self.start_time, self.stop_time || Time.now)
    end

  end

  private

  def add_cost(from_time, to_time)
    run_time = (to_time - from_time) / AN_HOUR
    run_time_in_hr = run_time.to_i < run_time ? run_time + 1 : run_time

    costs.create!(:amount => run_time_in_hr * hourly_run_cost, :upto => to_time, :billing_owner => server.billing_owner)
  end

  def hourly_run_cost
    YAML.load_file(File.join(File.dirname(__FILE__), "../../config/costs.yml"))[self.region][self.flavor]
  end

  def has_one_hour_passed?(cost_recorded_upto)
    (Time.now - cost_recorded_upto) > AN_HOUR
  end

  def all_tags_are_same(other)
    self.tags.size == other.tags.size && each_tag_exists(other.tags, self.tags) && each_tag_exists(self.tags, other.tags)
  end

  def each_tag_exists(tags, other_tags)
    tags.each do |tag|
      found = false
      other_tags.each do |other_tag|
        if tag.is_same?(other_tag)
          found = true
          break
        end
      end
      unless found
        return false
      end
    end
    true
  end

end