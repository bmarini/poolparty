require "test_helper"

class ChefCompileTest < Test::Unit::TestCase
  context "Chef" do
    setup do
      @scratch_dir = File.expand_path("../../scratch/tmp/poolparty", __FILE__)
      @fixture_dir = File.expand_path("../../scratch/tmp/poolparty", __FILE__)
      FileUtils.rm_rf File.expand_path("../../scratch/tmp", __FILE__)
    end

    context "client compilation" do
      setup do
        pool   = PoolParty::Pool.new("test")
        cloud  = PoolParty::Cloud.new("test", pool)
        @chef  = PoolParty::ChefClient.new(cloud)

        @chef.server_url= "http://localhost:4000"
        @chef.roles = ["base", "app"]
        @chef.add_recipe "nginx::source"
        @chef.add_recipe "varnish"
        @chef.attributes = { :nginx => { :listen_ports => ["80", "8080"] } }
      end

      should "create create the right files for default init style" do
        @chef.compile!("#{@scratch_dir}/client/default")
        assert_equal_files("#{@fixture_dir}/client/default/etc/chef/client.rb", "#{@scratch_dir}/client/default/etc/chef/client.rb")
        assert_equal_files("#{@fixture_dir}/client/default/etc/chef/dna.json", "#{@scratch_dir}/client/default/etc/chef/dna.json")
      end

      should "create the right files for bootstrap init style" do
        @chef.init_style = "upstart"
        @chef.compile!("#{@scratch_dir}/client/bootstrap")
        assert_equal_files("#{@fixture_dir}/client/bootstrap/etc/chef/dna.json", "#{@scratch_dir}/client/bootstrap/etc/chef/dna.json")
        assert_equal_files("#{@fixture_dir}/client/bootstrap/tmp/chef/chef.json", "#{@scratch_dir}/client/bootstrap/tmp/chef/chef.json")
        assert_equal_files("#{@fixture_dir}/client/bootstrap/tmp/chef/solo.rb", "#{@scratch_dir}/client/bootstrap/tmp/chef/solo.rb")
      end

    end

    context "solo compilation" do
      setup do
        @pool   = PoolParty::Pool.new("test-pool")
        @cloud  = PoolParty::Cloud.new("test-cloud", @pool)
        @chef   = PoolParty::ChefSolo.new(@cloud)
        @chef.repo = File.expand_path("../../fixtures/chef", __FILE__)
        @chef.add_recipe "nginx::source"
        @chef.add_recipe "varnish"
        @chef.attributes = { :nginx => { :listen_ports => ["80", "8080"] } }
        @chef.compile!("#{@scratch_dir}/solo/default")
      end

      should "create all the right files" do
        assert_equal_files("#{@fixture_dir}/solo/default/etc/chef/solo.rb", "#{@scratch_dir}/solo/default/etc/chef/solo.rb")
        assert_equal_files("#{@fixture_dir}/solo/default/etc/chef/dna.json", "#{@scratch_dir}/solo/default/etc/chef/dna.json")
        assert_equal_files("#{@fixture_dir}/solo/default/etc/chef/roles/test-cloud.json", "#{@scratch_dir}/solo/default/etc/chef/roles/test-cloud.json")
      end
    end
  end
end
