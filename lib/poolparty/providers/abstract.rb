module PoolParty
  module Providers
    class Abstract
      attr_accessor :name

      def initialize(cloud)
        @cloud = cloud
      end

      def run
      end

      def bootstrap_nodes!(tmp_path)
      end

      def configure_nodes!(tmp_path)
      end

      def reset!
      end

      def run_instance(opts)
      end

      def terminate_instance!(opts)
      end

      def describe_instances(opts)
      end

      def describe_instance(opts)
      end

      def security_groups
        []
      end

      # TODO: This method should be defined in a DSL class ProviderBlock
      def security_group(name, opts={}, &block)
      end

      def nodes
        []
      end

      def autoscalers
        []
      end
    end
  end
end