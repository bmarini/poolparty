=begin rdoc
  Base class for all PoolParty objects
=end
module PoolParty
  
  class Base
    include Dslify
    attr_reader :name

    def initialize(name, opts={}, &block)
      @name = name
      @init_opts = opts
      set_vars_from_options(opts)
      instance_eval(&block) if block_given?
      after_initialized
    end

    def after_initialized
    end

    def run
      raise NotImplementedError, "Please implement the run method"
    end

    def method_missing(name, *args, &block)
      if parent.respond_to?(name)
        parent.send(name, *args, &block)
      else
        super
      end
    end

    private
  end

end