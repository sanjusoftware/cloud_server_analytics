require "yaml"
require "active_record"
class Database

  def self.establish_connection
    database_config = File.join(File.dirname(__FILE__), "../config/database.yml")
    ActiveRecord::Base.establish_connection(YAML.load_file(database_config))
  end

  def self.create_database
    self.establish_connection
    require File.dirname(File.realpath(__FILE__)) + '/../db/schema'
  end

end


