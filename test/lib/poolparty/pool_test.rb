require "test_helper"

stub_keypair_searchable_paths

class PoolTest < Test::Unit::TestCase
  context "Pool" do
    setup do
      reset!
    end

    should "create a global pool object" do
      pool "hi" do
      end
      assert_equal @@pool.name, "hi"
    end

    should "create a cloud" do
      pool = PoolParty::Pool.new :test
      pool.cloud "project1" do
        using :ec2
      end

      assert_instance_of PoolParty::Cloud, pool.clouds["project1"]
    end

  end
end