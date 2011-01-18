module PoolParty
  module Dsl
    class CloudBlock
      def self.evaluate(name, pool, &block)
        builder = new(name, pool)
        builder.instance_eval(&block)
        builder.to_definition
      end

      def initialize(name, pool)
        @cloud = Cloud.new(name, :parent => pool, :using => :ec2)
      end

      def keypair(path)
        @cloud.keypair(path)
      end

      def instances(arg)
        @cloud.instances(arg)
      end

      def upload(src, dst)
        @cloud.upload(src, dst)
      end

      def using(provider, &block)
        @cloud.using(provider, &block)
      end

      def chef(type, &block)
        @cloud.chef = ChefBlock.evaluate(type, self, &block)
      end

      def to_definition
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
