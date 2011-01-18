module PoolParty
  class ChefAttribute < Hash
    def to_dna(recipes, filepath, opts=nil)
      ChefDnaFile.to_dna(recipes, filepath, opts || self)
    end
  end
end
