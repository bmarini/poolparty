module PoolParty
  module Dsl
    class Main
      def self.evaluate(spec)
        builder = new
        builder.instance_eval(spec, __FILE__, __LINE__ + 1)
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
  end
end