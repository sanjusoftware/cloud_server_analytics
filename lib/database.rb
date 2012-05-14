require "yaml"
require "active_record"
module CloudServerAnalytics
  class Database

    def self.establish_connection(env)
      database_config = YAML.load_file(File.join(File.dirname(__FILE__), "../config/database.yml"))
      ActiveRecord::Base.establish_connection(database_config[env])
    end

    def self.create_database
      require File.dirname(File.realpath(__FILE__)) + '/../db/schema'
    end

  end
end


