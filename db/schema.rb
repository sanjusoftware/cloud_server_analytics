ActiveRecord::Schema.define :version => 0 do
  create_table :servers, :force => true do |t|
    t.string :name
    t.string :billing_owner
  end

  create_table :runs, :force => true do |t|
    t.integer :server_id
    t.datetime :start_time
    t.datetime :stop_time
    t.string :region
    t.string :state
    t.string :flavor
  end

  create_table :tags, :force => true do |t|
    t.integer :run_id
    t.string :key
    t.string :value
  end

  create_table :utilizations, :force => true do |t|
    t.integer :server_id
    t.string :type
    t.string :unit
    t.float :average
    t.float :samples
    t.timestamp :timestamp
    end

  create_table :costs, :force => true do |t|
    t.integer :run_id
    t.float :amount
    t.timestamp :upto
  end
end