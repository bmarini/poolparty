require "test_helper"

class BaseTest < Test::Unit::TestCase
  context "Base" do
    should "require run to be implemented" do
      assert_raise NotImplementedError do
        PoolParty::Base.new(:test).run
      end
    end
  end
end