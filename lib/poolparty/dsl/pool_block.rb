module PoolParty
  module Dsl
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
  end
end