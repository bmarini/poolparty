module PoolParty
  module Dsl
    autoload :Main, "poolparty/dsl/main"
    autoload :PoolBlock, "poolparty/dsl/pool_block"
    autoload :CloudBlock, "poolparty/dsl/cloud_block"
    autoload :ChefBlock, "poolparty/dsl/chef_block"

    def self.load(file)
      evaluate( File.read(file) )
    end

    def self.evaluate(spec)
      Main.evaluate(spec)
    end

    module Properties
      def attribute(*names)
        names.each do |name|
          class_eval %Q{
            def #{name}(val=nil)
              @#{name} = val unless val.nil?
              @#{name}
            end
          }
        end
      end
    end
  end
end