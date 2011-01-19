module PoolParty
  module Dsl
    class CloudBlock
      def self.evaluate(name, pool, &block)
        builder = new(name, pool)
        builder.instance_eval(&block)
        builder.to_definition
      end

      def initialize(name, pool)
        @cloud = Cloud.new(name, pool)
      end

      def keypair(path)
        @cloud.keypair = path
      end

      def instances(arg)
        case arg
        when Range
          @cloud.minimum_instances = arg.first
          @cloud.maximum_instances = arg.last
        when Fixnum
          @cloud.minimum_instances = arg
          @cloud.maximum_instances = arg
        when Hash
          @cloud.nodes(arg)
        else
          raise ArgumentError, "You must call instances with either a number, a range or a hash (for a list of nodes)"
        end
      end

      def upload(src, dst)
        @cloud.add_upload(src, dst)
      end

      def using(provider, &block)
        @cloud.provider = CloudProviders.const_get(provider.to_s.capitalize).new(provider, :cloud => @cloud, &block)
      end

      def chef(type, &block)
        @cloud.chef = ChefBlock.evaluate(type, self, &block)
      end

      def to_definition
        @cloud.set_default_security_group
        @cloud
      end

      # Delegate to the cloud class for now
      def method_missing(name, *args, &block)
        if @cloud.respond_to?(name)
          @cloud.send(name, *args, &block)
        else
          super
        end
      end
    end
  end
end
