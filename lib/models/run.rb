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
  end

  def is_same?(other)
    self.region == other.region &&
        self.state == other.state &&
        self.flavor == other.flavor &&
        all_tags_are_same(other)
  end

  def add_hourly_cost
    costs_config = YAML.load_file(File.join(File.dirname(__FILE__), "../../config/costs.yml"))
    cost_records = costs.order("up_to desc")
    if cost_records.present?
      last_upto = cost_records.last().upto
      if one_hour_has_passed_since_last_cost_record(last_upto)
        costs.new(:amount => costs_config[self.region][self.flavor], :upto => last_upto + AN_HOUR)
      end
    else
      end_time = self.stop_time || Time.now
      run_time = (end_time - self.start_time) / AN_HOUR
      run_time_in_hr = run_time.to_i < run_time ? run_time + 1 : run_time
      costs.new(:amount => run_time_in_hr * costs_config[self.region][self.flavor], :upto => end_time)
    end
  end

  private

  def one_hour_has_passed_since_last_cost_record(cost_recorded_upto)
    (Time.now - cost_recorded_upto) < AN_HOUR
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