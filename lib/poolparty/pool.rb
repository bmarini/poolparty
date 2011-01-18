module PoolParty
  class Pool
    attr_reader :name, :clouds
    attr_accessor :verbose, :very_verbose, :debugging, :very_debugging, :auto_execute

    def initialize(name)
      @name   = name
      @clouds = []
    end

    def add_cloud(cloud)
      @clouds.push(cloud)
    end

    # Run command/s on all nodes in the pool.
    # Returns a hash in the form of {cloud => [{instance_id=>result}]}
    def cmd(commands, opts={})
      results = {}

      threads = clouds.collect do |cloud|
        Thread.new { results[cloud.name] = cloud.cmd(commands, opts) }
      end

      threads.each { |t| t.join }

      results
    end
    
    # === Description
    #
    # Set / Get the chef_step which will be executed on the remote
    # host
    def chef_step(name=nil)
      @chef_step ||= :default
      @chef_step = name.to_sym if name
      @chef_step
    end

    def run
      clouds.each do |cloud|
        puts "----> Starting to build cloud #{cloud.name}"
        cloud.run
      end
    end

    def to_hash
      c = clouds.collect do |cloud|
        nodes = cloud.nodes.collect do |node|
          {
            :dns_name   => node[:dns_name],
            :private_ip => node[:private_ip],
            :public_ip  => node[:public_ip]
          }
        end

        { cloud.name => nodes }
      end

      h = c.inject({}) do |memo, cloud_hash|
        memo.merge!(cloud_hash)
      end 

      {:clouds => h }
    end

  end

end
