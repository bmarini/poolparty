module PoolParty
  module Dsl
    class Main
      def self.evaluate(spec)
        builder = new
        builder.instance_eval(spec)
        builder.to_definition
      end

      def initialize
        @pools = []
      end

      def pool(name=:default, &block)
        @pools << PoolBlock.evaluate(name, &block)
      end

      def to_definition
        @pools
      end
    end

    class PoolBlock
      def self.evaluate(name, &block)
        builder = new(name)
        builder.instance_eval(&block)
        builder.to_definition
      end

      def initialize(name)
        @pool = Pool.new(name)
      end

      def cloud(name, &block)
        @pool.add_cloud CloudBlock.evaluate(name, @pool, &block)
      end

      def to_definition
        @pool
      end
    end


    class CloudBlock
      def self.evaluate(name, pool, &block)
        builder = new(name, pool)
        builder.instance_eval(&block)
        builder.to_definition
      end

      def initialize(name, pool)
        @cloud = Cloud.new(name, :parent => pool)
      end

      def keypair(path)
        @cloud.keypair(path)
      end

      def instances(arg)
        @cloud.instances(path)
      end

      def to_definition
        @cloud
      end
    end
  end
end