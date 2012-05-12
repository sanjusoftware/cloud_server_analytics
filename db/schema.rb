ActiveRecord::Schema.define :version => 0 do
  create_table :runs, :force => true do |t|
    t.string :instance_id
    t.datetime :start_time
    t.datetime :stop_time
    t.string :ec2_region
    t.string :state
    t.string :flavor
    end

  create_table :tags, :force => true do |t|
    t.string :instance_id
    t.string :key
    t.string :value
    end

  create_table :utilizations, :force => true do |t|
    t.string :instance_id
    t.string :type
    t.string :unit
    t.float :average
    t.float :samples
    t.timestamp :timestamp
  end
end