require "test_helper"

stub_keypair_searchable_paths

class PoolTest < Test::Unit::TestCase
  context "Pool" do
    should "create a global pool object" do
      pools = PoolParty::Dsl.evaluate <<-EOF
        pool "hi" do
        end
      EOF

      assert_equal pools.first.name, "hi"
    end

    should "create a cloud" do
      pools = PoolParty::Dsl.evaluate <<-EOF
        pool :test do
          cloud "project1" do
            using :ec2
          end
        end
      EOF

      assert_instance_of PoolParty::Cloud, pools.first.clouds.first
    end

  end
end