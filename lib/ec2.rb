module CloudServerAnalytics
  class EC2

    @@conn = nil

    def self.conn
      if @@conn
        @@conn
      else
        aws_config = YAML.load_file(File.join(File.dirname(__FILE__), "../config/secret_key.yml"))
        @@conn = AWS::EC2::Base.new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
        @@conn
      end
    end

    def load_instances
      Database.establish_connection
      instance_descriptions = EC2.conn.describe_instances
      instances = instance_descriptions["reservationSet"]["item"]
      instances.each do |instance_hash|
        instance = instance_hash["instancesSet"]["item"][0]
        create_new_run(Run.find_by_instance_id(instance["instanceId"]) || Run.new, instance)
        create_instance_tags(instance)
      end
    end

    private

    def create_new_run(run, instance)

      run.instance_id = instance["instanceId"]
      availability_zone = instance["placement"]["availabilityZone"]
      run.ec2_region = availability_zone[0, (availability_zone.length-1)]
      run.start_time = Time.parse(instance["launchTime"])
      run.flavor = instance["instanceType"]
      status = instance["instanceState"]["name"]
      run.state = status if Run::VALID_STATES.include? status
      if status.eql? 'stopped'
        run.stop_time = extract_stop_time(instance)
      end
      run.save!
    end

    def extract_stop_time(instance)
      time_part = instance["reason"].split('(')[1]
      Time.parse(time_part[0, (time_part.length - 1)])
    end

    def create_instance_tags(instance)
      instance["tagSet"]["item"].each do |tag|
        Tag.create!(:instance_id => instance["instanceId"], :key => tag["key"], :value => tag["value"])
      end
    end
  end

end