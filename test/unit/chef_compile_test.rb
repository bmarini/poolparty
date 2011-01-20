require "test_helper"

class ChefCompileTest < Test::Unit::TestCase

  context "Chef client compilation" do
    setup do
      pool   = PoolParty::Pool.new("test")
      cloud  = PoolParty::Cloud.new("test", pool)
      @chef = PoolParty::ChefClient.new(cloud)

      @chef.server_url= "http://localhost:4000"
      @chef.roles = ["base", "app"]
      @chef.add_recipe "nginx::source"
      @chef.add_recipe "varnish"
      @chef.attributes = { :nginx => { :listen_ports => ["80", "8080"] } }
    end

    should "create create the right files for default init style" do
      @chef.compile!
      tmp_dir = "/tmp/poolparty/test/test/etc/chef"
      assert File.exist?(tmp_dir)

        expected = <<-EOF.strip
{
  "run_list": [
    "role[base]",
    "role[app]",
    "recipe[nginx::source]",
    "recipe[varnish]"
  ],
  "nginx": {
    "listen_ports": [
      "80",
      "8080"
    ]
  }
}
        EOF
        assert_equal JSON.parse(expected, :create_additions => false),
                     JSON.parse(File.read("#{tmp_dir}/dna.json"), :create_additions => false)

        expected = <<-EOF
log_level          :info
log_location       "/var/log/chef/client.log"
ssl_verify_mode    :verify_none
file_cache_path    "/var/cache/chef"
pid_file           "/var/run/chef/client.pid"
Chef::Log::Formatter.show_time = true
openid_url         "http://localhost:4001"
chef_server_url    "http://localhost:4000"
        EOF

        assert_equal expected, File.read("#{tmp_dir}/client.rb")
    end

    should "create the right files for bootstrap init style" do
      @chef.init_style = "upstart"
      @chef.compile!

      assert File.exist?("/tmp/poolparty/test/test/tmp/chef")

      expected = <<-EOF
file_cache_path "/tmp/chef-solo"
cookbook_path "/tmp/chef-solo/cookbooks"
recipe_url "http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz"
      EOF

      assert_equal expected, File.read("/tmp/poolparty/test/test/tmp/chef/solo.rb")

      expected = {
        "bootstrap" => {
          "chef" => {
            "url_type" =>  "http",
            "init_style" => "upstart",
            "path" => "/srv/chef",
            "serve_path" => "/srv/chef",
            "server_fqdn" => "localhost",
            "server_port" => 4000,
          }
        },
        "run_list" => [ 'recipe[bootstrap::client]' ]
      }

      assert_equal expected, JSON.parse(File.read("/tmp/poolparty/test/test/tmp/chef/chef.json"))
    end

  end

  context "Chef solo compilation" do

    setup do
      @pool   = PoolParty::Pool.new("test-pool")
      @cloud  = PoolParty::Cloud.new("test-cloud", @pool)
      @chef   = PoolParty::ChefSolo.new(@cloud)
      @chef.repo = File.expand_path("../../fixtures/chef", __FILE__)
      @chef.add_recipe "nginx::source"
      @chef.add_recipe "varnish"
      @chef.attributes = { :nginx => { :listen_ports => ["80", "8080"] } }
      @chef.compile!
    end

    should "create all the right files" do
      tmp_dir = "/tmp/poolparty/test-pool/test-cloud/etc/chef"

      assert File.exist?(tmp_dir)

      expected = <<-EOF.strip
{
  "run_list": [
    "role[test-cloud]"
  ]
}
      EOF
      assert_equal expected, File.read("#{tmp_dir}/dna.json")

      expected = <<-EOF.strip
{
  "recipes": [
    "nginx::source",
    "varnish"
  ],
  "json_class": "Chef::Role",
  "default_attributes": {
    "nginx": {
      "listen_ports": [
        "80",
        "8080"
      ]
    }
  },
  "override_attributes": {
    "poolparty": {
      "parent_name": "test-pool",
      "name": "test-cloud",
      "pool_info": {
        "clouds": {

        }
      }
    }
  },
  "chef_type": "role",
  "description": "PoolParty cloud",
  "name": "test-cloud"
}
        EOF

        assert_equal JSON.parse(expected, :create_additions => false),
                     JSON.parse(File.read("#{tmp_dir}/roles/test-cloud.json"), :create_additions => false)
    end
  end
end
