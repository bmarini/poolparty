module PoolParty
  class ChefDnaFile
    def self.to_dna(recipes, filepath, atts)
      normalize_data(recipes, atts)
      write_file(filepath, atts)
    end

    def self.normalize_data(recipes, atts)
      if recipes && !recipes.empty?
        atts[:recipes] ||= []
        atts[:recipes] += recipes
      end

      atts.delete(:name) if atts[:name] && atts[:name].empty?
    end

    def self.write_file(filepath, atts)
      File.open(filepath, "w") { |f| f << JSON.pretty_generate(atts) }
    end
  end
end