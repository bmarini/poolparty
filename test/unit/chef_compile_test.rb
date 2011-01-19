require "test_helper"

class ChefCompileTest < Test::Unit::TestCase

  # TODO: Test tmp dir compilation instead
  context "Chef DNA" do

    should "create dna for chef client" do
      pool   = PoolParty::Pool.new("test")
      cloud  = PoolParty::Cloud.new("test", pool)
      client = PoolParty::ChefClient.new(cloud)

      client.roles = ["base", "app"]
      client.add_recipe "nginx::source"
      client.add_recipe "varnish"
      client.attributes = { :nginx => { :listen_ports => ["80", "8080"] } }

      dnafile = nil

      begin
        dnafile = Tempfile.new("dna.json")

        client.attributes.to_dna(
          [], dnafile.path, { :run_list => client.roles.map { |r| "role[#{r}]"} + client._recipes.map { |r| "recipe[#{r}]" } }.merge(client.attributes)
        )

        dnafile.rewind
        result = dnafile.read
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
        assert_equal JSON.parse(expected, :create_additions => false), JSON.parse(result, :create_additions => false)
      ensure
        dnafile.close
        dnafile.unlink
      end

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
