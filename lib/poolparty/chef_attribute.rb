module PoolParty
  class ChefAttribute < Base
    attr_reader :init_opts

    def initialize(opts={}, &block)
      @init_block = block
      @init_opts = opts
      instance_eval &block if block
      @base_name = self.name
    end

    def merge!(h={})
      init_opts.merge!(h)
    end

    def to_dna(recipes, filepath, opts=init_opts)
      # self.class.to_dna(opts, recipes, filepath)

      if recipes && !recipes.empty?
        (opts[:recipes] ||= []) << recipes
        opts[:recipes].flatten!
      end
      
      opts.delete(:name) if opts[:name] && opts[:name].empty?
      File.open(filepath, "w") do |f|
        f << JSON.pretty_generate(opts)
      end
    end

    def self.to_dna(filepath, atts, recipes=[])
      normalize_atts!(atts, recipes)
      write_file(filepath, atts)
    end

    def self.normalize_atts!(atts, recipes)
      # Add some additional recipes
      if recipes && !recipes.empty?
        atts[:recipes] ||= []
        atts[:recipes] += recipes
      end

      # Remove name if it is blank
      atts.delete(:name) if atts[:name] && atts[:name].empty?
    end

    def self.write_file(filepath, atts)
      File.open(filepath, "w") { |f| f << JSON.pretty_generate(atts) }
    end

    def method_missing(m,*a,&block)
      if @init_opts.has_key?(m)
        @init_opts[m]
      else
        @init_opts.merge!(m => a)
      end
    end

  end
end
