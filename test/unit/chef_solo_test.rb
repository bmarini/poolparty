require "test_helper"

class ChefSoloTest < Test::Unit::TestCase

  # chef :solo do
  #   repo File.dirname(__FILE__) + "/chef_cloud/chef_repo"
  #   recipe "apache2"
  #   recipe "rsyslog::server"
  #   recipe "collectd"
  #   attributes :apache2 => {:listen_ports => ["80", "8080"]}
  # end

  context "Chef Solo DSL" do
    setup do
      @chef = PoolParty::Chef.get_chef(:solo, nil)
    end

    should "support repo" do
      chef_repo = File.expand_path("..", __FILE__)
      @chef.repo chef_repo
      assert_equal chef_repo, @chef.repo
    end

    should "support recipe" do
      @chef.recipe "apache2"
      @chef.recipe "rsyslog::server"
      assert_equal ["apache2", "rsyslog::server"], @chef._recipes
    end

    should "support override attributes for recipes" do
      @chef.recipe "apache2", :config => "foo"
      expected_atts = { "apache2" => { :config => "foo" } }

      assert_equal ["apache2"], @chef._recipes
      assert_equal expected_atts, @chef.override_attributes.init_opts
    end

    should "support attributes" do
      expected_atts = { :apache2 => { :listen_ports => ["80", "8080"] } }
      @chef.attributes expected_atts
      assert_equal expected_atts, @chef.attributes.init_opts
    end
  end
end