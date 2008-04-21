require 'yaml'
require 'net/ssh'
module Tunnlr
    
  class Connector
    
    def initialize
      @config = read_configuration
      @should_disconnect =false
    end
    
    def connect!
      @should_disconnect=false
      Net::SSH.start(host,username,:password=>password) do |ssh|
        puts "Connecting to #{username}@#{host} and sending #{remote_port}->#{local_port}"
        ssh.forward.remote_to(local_port,'127.0.0.1',remote_port,'0.0.0.0')
        puts "You can view your tunneled connection at http://web1.tunnlr.com:#{remote_port}/"
        ssh.loop {!@should_disconnect}
      end
    end
    
    def disconnect!
      @should_disconnect=true
    end
    
    def read_configuration
      path = File.join(RAILS_ROOT, "config/tunnlr.yml")
      YAML.load(File.read(path))
    end
        
    def method_missing(name,*args)
      if @config[name.to_s]
        @config[name.to_s]
      else
        super
      end
    end
  end
end
