require "test_helper"

class ChefSoloTest < Test::Unit::TestCase

  # chef :solo do
  #   repo File.dirname(__FILE__) + "/chef_cloud/chef_repo"
  #   recipe "apache2"
  #   recipe "rsyslog::server"
  #   recipe "collectd"
  #   attributes :apache2 => {:listen_ports => ["80", "8080"]}
  # end

  context "Chef Solo" do
    setup { @chef = PoolParty::ChefSolo.new(nil) }

    should "define binary" do
      assert_equal "chef-solo", @chef.send(:chef_bin)
    end

    should "define command" do
      assert_match /chef-solo -j \/etc\/chef\/dna\.json -c \/etc\/chef\/solo\.rb/, @chef.send(:chef_cmd)
    end
  
  end

  context "Chef Solo DSL" do
    setup do
      pool  = PoolParty::Pool.new("test")
      cloud = PoolParty::Cloud.new("proj", pool)
      @chef = PoolParty::ChefSolo.new(cloud)
    end

    should "support repo" do
      chef_repo = File.expand_path("..", __FILE__)
      @chef.repo = chef_repo
      assert_equal chef_repo, @chef.repo
    end

    should "support recipe" do
      @chef.add_recipe "apache2"
      @chef.add_recipe "rsyslog::server"
      assert_equal ["apache2", "rsyslog::server"], @chef._recipes
    end

    should "support override attributes for recipes" do
      @chef.add_recipe "apache2", :default, :config => "foo"
      @chef.add_recipe "nginx::source", :default, :config => "bar"
      expected_atts = {
        "apache2" => { :config => "foo" },
        "nginx" => { :config => "bar" }
      }

      assert_equal ["apache2", "nginx::source"], @chef._recipes
      assert_equal expected_atts, @chef.override_attributes
    end

    should "support attributes" do
      expected_atts = { :apache2 => { :listen_ports => ["80", "8080"] } }
      @chef.attributes = expected_atts
      assert_equal expected_atts, @chef.attributes
    end
  end
end