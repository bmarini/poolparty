require "test_helper"

class ChefAttributeTest < Test::Unit::TestCase
  context "Chef attribute" do
    should "initialize with a hash" do
      expected  = { :foo => :bar }
      attribute = PoolParty::ChefAttribute[expected]
      assert_equal expected, attribute
    end
  end
end
