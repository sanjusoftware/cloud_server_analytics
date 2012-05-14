module CloudServerAnalytics
  class API

    @conn = nil

    def conn
      if @conn
        @conn
      else
        aws_config = YAML.load_file(File.join(File.dirname(__FILE__), "../config/secret_key.yml"))
        @conn = eval(conn_obj).new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
        @conn
      end
    end

  end
end
