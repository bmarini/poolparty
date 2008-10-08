module PoolParty
  module MethodMissingSugar

    def method_missing(m, *args, &block)
      if block_given?
        (args[0].class == self.class) ? args[0].instance_eval(&block) : super
      else
        get_from_options(m, *args)
      end
    end
    
    def get_from_options(m, *args)
      args.empty? ? options[m] : options[m] = (args.is_a?(Array) && args.size > 1) ? args : args[0]
    end
    
  end
end