require "test_helper"

class DslTest < Test::Unit::TestCase
  context "Dsl" do
    should "evaluate a simple example" do
      pools = PoolParty::Dsl.evaluate <<-EOF
        pool "test" do
          cloud "project_a" do
            using :ec2
            keypair "/etc/chef/project_a.pem"
            instances 1..2
          end
        end
      EOF

      assert_equal 1, pools.size
      assert_equal "test", pools.first.name
      assert_equal "/etc/chef/project_a.pem", pools.first.clouds.first.keypair.filepath

    end

    should "evaluate a simple example with chef solo" do
      pools = PoolParty::Dsl.evaluate <<-EOF
        pool "test" do
          cloud "project_a" do
            using :ec2
            keypair "/etc/chef/project_a.pem"
            instances 1..2

            chef :solo do
              repo File.dirname(__FILE__) + "/chef_cloud/chef_repo"
              recipe "apache2"
              recipe "rsyslog::server"
              recipe "collectd"
              attributes :apache2 => { :listen_ports => ["80", "8080"] }
            end
          end
        end
      EOF

      assert_equal 1, pools.size
    end

    should "evaluate an example with chef client" do
      pools = PoolParty::Dsl.evaluate <<-EOF
        pool "test" do
          cloud "project_a" do
            using :ec2

            chef :client do
              server_url "http://chef-server.domain.tld:4000"
              validation_token "/etc/chef/validation"
              validation_key "/etc/chef/validation.pem"
              validation_client_name "chef-validator"

              roles "app"
              recipe "collectd"
              attributes :apache2 => {:listen_ports => ["80", "8080"]}
            end
          end
        end
      EOF

      assert_equal 1, pools.size
    end
  end
end