require "test_helper"

class ChefTest < Test::Unit::TestCase

  # chef :client do
  #   server_url "http://chef-server.domain.tld:4000"
  #   validation_token "/etc/chef/validation"
  #   validation_key "/etc/chef/validation.pem"
  #   validation_client_name "chef-validator"
  #
  #   roles "app"
  #   recipe "collectd"
  #   attributes :apache2 => {:listen_ports => ["80", "8080"]}
  # end

  context "Chef Client DSL" do
    setup do
      @chef = PoolParty::Chef.get_chef(:client, nil) { |c| c.server_url = "http://localhost:4000" }
    end

    should "support server_url" do
      @chef.server_url "http://chef-server.domain.tld:4000"
      assert_equal "http://chef-server.domain.tld:4000", @chef.server_url
    end

    should "support validation_token" do
      @chef.validation_token "/etc/chef/validation"
      assert_equal "/etc/chef/validation", @chef.validation_token
    end

    should "support validation_key" do
      @chef.validation_key "/etc/chef/validation.pem"
      assert_equal "/etc/chef/validation.pem", @chef.validation_key
    end

    should "support validation_client_name" do
      @chef.validation_client_name "chef-validator"
      assert_equal "chef-validator", @chef.validation_client_name
    end

    should "support role" do
      @chef.roles "app"
      assert_equal ["app"], @chef.instance_eval { @_roles }
    end
  end
end