module CloudServerAnalytics
  class AmazonEC2
    require 'aws'
    require 'run'
    require 'tag'
    require 'database'
    require 'time'


    @@ec2 = nil

    def self.conn
      if @@ec2
        @@ec2
      else
        @@ec2 = AWS::EC2::Base.new(:access_key_id => "AKIAIUYCZBPB2N6Q64WQ", :secret_access_key => "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")
        @@ec2
      end
    end

    def load_instances
      Database.establish_connection
      instance_descriptions = AmazonEC2.conn.describe_instances
      instances = instance_descriptions["reservationSet"]["item"]
      instances.each do |instance_hash|
        instance = instance_hash["instancesSet"]["item"][0]
        create_new_run(Run.find_by_instance_id(instance["instanceId"]) || Run.new, instance)
        create_instance_tags(instance)
      end
    end

    private

    def create_new_run(run, instance)
      puts instance["instanceState"]["name"]
      puts instance["placement"]["availabilityZone"]
      puts instance["instanceType"]
      puts instance["launchTime"]
      puts instance["reason"]

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