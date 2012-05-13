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
        instance_id = instance["instanceId"]
        server = Server.find_by_name(instance_id)
        new_run = create_new_run(instance)

        if server
          run = server.current_run
          if run and !run.is_same?(new_run)
            run.stop
            server.runs << new_run
          end
        else
          server = Server.new(:name => instance_id)
          server.runs << new_run
        end

        server.save!
      end
    end

    def stop_server(server_name)
      Database.establish_connection
      server = Server.find_by_name(server_name)
      if server
        EC2.conn.stop_instances(:instance_id => server_name)
        server.current_run.stop
      else
        raise "Invalid server instance provided #{server_name}"
      end
    end

    def print_report(options)
      STDOUT.write "#{options[:tp].upcase} | #{options[:v].upcase} | #{options[:a].upcase}\n"
    end

    private

    def create_new_run(instance)
      run = Run.new
      availability_zone = instance["placement"]["availabilityZone"]
      run.region = availability_zone[0, (availability_zone.length-1)]
      run.start_time = Time.parse(instance["launchTime"])
      run.flavor = instance["instanceType"]
      status = instance["instanceState"]["name"]
      run.state = status if Run::VALID_STATES.include? status
      if status.eql? 'stopped'
        run.stop_time = extract_stop_time(instance)
      end
      create_tags(instance, run)
      run
    end

    def create_tags(instance, run)
      instance["tagSet"]["item"].each do |tag|
        run.tags.new(:key => tag["key"], :value => tag["value"])
      end
    end

    def extract_stop_time(instance)
      time_part = instance["reason"].split('(')[1]
      Time.parse(time_part[0, (time_part.length - 1)])
    end
  end

end