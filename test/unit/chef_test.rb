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

  context "Chef DSL" do
    setup do
      @chef = PoolParty::Chef.get_chef(:solo, nil)
    end

    should "support recipes" do
      @chef.recipes "apache2", "varnish"
      assert_equal ["apache2", "varnish"], @chef._recipes
    end

    # on_step :download_install do
    #     recipe "myrecipes::download"
    #     recipe "myrecipes::install"
    # end
    #
    # on_step :run => :download_install do
    #     recipe "myrecipes::run"
    # end

    should "support on_step" do
      @chef.on_step :download_install do
        recipe "myrecipes::download"
        recipe "myrecipes::install"
      end

      @chef.on_step :run => :download_install do
        recipe "myrecipes::run"
      end

      assert_equal [], @chef._recipes
      assert_equal ["myrecipes::download", "myrecipes::install"], @chef._recipes(:download_install)

      assert_equal ["myrecipes::download", "myrecipes::install", "myrecipes::run"], @chef._recipes(:run)
    end
  end
end