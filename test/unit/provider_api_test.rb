require "test_helper"

class ProviderApiTest < Test::Unit::TestCase
  context "Abstract Provider" do
    setup do
      pool = PoolParty::Pool.new("test")
      @cloud = PoolParty::Cloud.new("test", pool)
      @cloud.provider = PoolParty::Providers::Abstract.new(@cloud)
      @cloud.add_upload("source", "destination")
    end

    should "should respond to all methods cloud calls on it" do
      assert_nothing_raised { @cloud.run }
      assert_nothing_raised { @cloud.set_default_security_group }
      assert_raise(NotImplementedError) { @cloud.teardown }
      assert_nothing_raised { @cloud.reboot! }
      assert_nothing_raised { @cloud.compile! }
      assert_nothing_raised { @cloud.bootstrap! }
      assert_nothing_raised { @cloud.configure! }
      assert_nothing_raised { @cloud.reset! }

      assert_nothing_raised { @cloud.run_instance }
      assert_nothing_raised { @cloud.terminate_instance! }
      assert_nothing_raised { @cloud.describe_instances }
      assert_nothing_raised { @cloud.describe_instance }

    end
  end
end