module CloudServerAnalytics
  class AmazonEC2
    require 'aws-sdk'
    require 'run'
    require 'tag'
    require 'database'
    require 'time'


    @@ec2 = nil

    def self.conn
      if @@ec2
        @@ec2
      else
        @@ec2 = AWS::EC2.new(:access_key_id => "AKIAIUYCZBPB2N6Q64WQ", :secret_access_key => "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")
        @@ec2
      end
    end

    def load_instances
      AWS.memoize do
        Database.establish_connection
        AmazonEC2.conn.instances.each do |instance|
          create_new_run(Run.find_by_instance_id(instance.id) || Run.new, instance)
        end
      end
    end

    private

    def create_new_run(run, instance)
      run.instance_id = instance.id
      availability_zone = instance.availability_zone
      run.ec2_region = availability_zone[0, (availability_zone.length-1)]
      run.start_time = instance.launch_time
      run.flavor = instance.instance_type
      status = instance.status.to_s
      run.state = status if Run::VALID_STATES.include? status
      if status.eql? 'stopped'
        run.stop_time = extract_stop_time(instance)
      end
      run.save!
      create_instance_tags(instance)
    end

    def extract_stop_time(instance)
      time_part = instance.state_transition_reason.split('(')[1]
      Time.parse(time_part[0, (time_part.length - 1)])
    end

    def create_instance_tags(instance)
      instance.tags.each_pair do |tag_name, tag_value|
        Tag.create!(:instance_id => instance.id, :key => tag_name, :value => tag_value)
      end
    end
  end

end