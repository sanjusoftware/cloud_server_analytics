module CloudServerAnalytics
  class EC2 < API

    def conn_obj
      puts "came here"
      "AWS::EC2::Base"
    end

    def load_instances
      instance_descriptions = conn.describe_instances
      instances = instance_descriptions["reservationSet"]["item"]
      instances.each do |instance_hash|
        instance = instance_hash["instancesSet"]["item"][0]
        instance_id = instance["instanceId"]
        server = Server.find_by_name(instance_id)

        if server
          run = server.current_run
          new_run = create_new_run(server.runs.new, instance)
          if run and !run.is_same?(new_run)
            run.stop
            server.runs << new_run
            server.save!
          end
        else
          server = Server.create!(:name => instance_id)
          server.runs << create_new_run(server.runs.new, instance)
          server.save!
        end

      end
    end

    def stop_server(server_name)
      server = Server.find_by_name(server_name)
      if server
        conn.stop_instances(:instance_id => server_name)
        server.current_run.stop
      else
        raise "Invalid server instance provided #{server_name}"
      end
    end

    def idle_servers
      idle_servers = {}
      Server.all.each do |server|
        if server.is_idle?
          if idle_servers[server.billing_owner].present?
            idle_servers[server.billing_owner] << server.name
          else
            idle_servers[server.billing_owner] = [server.name]
          end
        end
      end
      idle_servers
    end

    def report(options)
      get_report(options, get_report_start_time(options) || Time.now, get_time_period(options))
    end

    private

    def get_report(options, start_time, time_period)
      case options[:v]
        when 'cost'
          output = get_cost_report(options, start_time, time_period)
        when 'utilization'
          output = get_utilization_report(options, start_time, time_period)
        else
          raise "The attribute value is not supported!!"
      end
      output
    end

    def get_time_period(options)
      case options[:tp]
        when 'day'
          time_period = 1.day
        when 'month'
          time_period = 1.month
        else
          time_period = 1.week
      end
      time_period
    end

    def get_report_start_time(options)
      if options[:st]
        begin
          return Time.parse(options[:st])
        rescue
          STDOUT.write "Start time is not provided or invalid. Taking it as current time.\n\n"
        end
      end
      nil
    end

    def get_utilization_report(options, start_time, time_period)
      output = ("#{options[:tp].upcase} | #{options[:v].upcase} | INSTANCE\n")
      end_time = Utilization.maximum(:timestamp)

      while start_time < end_time

        upto_time = start_time + time_period
        utilizations_for_time_period =
          Utilization.find_by_sql ["select avg(average) as utilization, server_id from utilizations where type = 'CPUUtilization' and timestamp > ? and timestamp < ? GROUP BY server_id ORDER BY utilization", start_time, upto_time]
        utilizations_for_time_period.each do |utilization|
          output.concat("#{start_time.strftime("%m/%d/%Y")} | #{utilization.utilization.to_f.round}% | #{utilization.server.name}\n")
        end
        start_time = upto_time
      end
      output
    end

    def get_cost_report(options, start_time, time_period)
      output = ("#{options[:tp].upcase} | #{options[:v].upcase} | #{options[:a].upcase}\n")
      end_time = Cost.maximum(:upto)

      while start_time < end_time

        upto_time = start_time + time_period
        costs_for_time_period = Cost.find_by_sql ["select sum(amount) as amount, billing_owner from costs where upto > ? and upto < ? GROUP BY billing_owner ORDER BY amount", start_time, upto_time]
        costs_for_time_period.each do |cost|
          output.concat("#{start_time.strftime("%m/%d/%Y")} | $#{cost.amount.round} | #{cost.billing_owner}\n")
        end
        start_time = upto_time
      end
      output
    end

    def create_new_run(run, instance)
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
        if tag["key"] == 'billing-owner'
          run.server.billing_owner = tag["value"]
          run.server.save!
        end
      end
    end

    def extract_stop_time(instance)
      time_part = instance["reason"].split('(')[1]
      Time.parse(time_part[0, (time_part.length - 1)])
    end
  end

end