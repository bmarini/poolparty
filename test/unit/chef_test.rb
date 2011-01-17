require "test_helper"

class ChefTest < Test::Unit::TestCase
  context "Chef" do
    should "have correct types" do
      assert_equal [:solo, :client], PoolParty::Chef.types
    end

    should "create solo and client instances" do
      assert_instance_of PoolParty::ChefSolo, PoolParty::Chef.get_chef(:solo, nil)
      assert_instance_of PoolParty::ChefClient,
        PoolParty::Chef.get_chef(:client, nil) { |c| c.server_url = "http://localhost:4000" }
    end

    should "have attributes" do
      assert_instance_of PoolParty::ChefAttribute, PoolParty::Chef.new(:test).attributes
      assert_instance_of PoolParty::ChefAttribute, PoolParty::Chef.new(:test).override_attributes
    end
  end
end