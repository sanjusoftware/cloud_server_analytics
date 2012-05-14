__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), "..","lib"))

$LOAD_PATH.unshift __LIB_DIR__ unless
  $LOAD_PATH.include?(__LIB_DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__LIB_DIR__))

require 'cloud_server_analytics'
require 'mocha'
require 'database_cleaner'

Database.establish_connection("test")
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.mock_framework = :mocha

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
