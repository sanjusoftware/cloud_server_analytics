class Run < ActiveRecord::Base
  belongs_to :server
  has_many :tags

  attr_accessible :server_id, :start_time, :stop_time, :region, :state, :flavor

  VALID_STATES = %w(running stopped terminated)
  RUNNING = 'running'
  STOPPED = 'stopped'
  TERMINATED = 'terminated'

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