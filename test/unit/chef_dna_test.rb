require "test_helper"

class ChefDnaTest < Test::Unit::TestCase

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

    should "create dna and role for chef solo" do
      pool   = PoolParty::Pool.new("test")
      cloud  = PoolParty::Cloud.new("chefcloud", pool)
      client = PoolParty::ChefSolo.new(cloud)

      client.repo = "/etc/chef/repo"
      client.add_recipe "nginx::source"
      client.add_recipe "varnish"
      client.attributes = { :nginx => { :listen_ports => ["80", "8080"] } }

      dnafile = nil

      begin
        dnafile = Tempfile.new("dna.json")

        client.attributes.to_dna [], dnafile.path, { :run_list => ["role[cloudname]"] }

        dnafile.rewind
        result = dnafile.read
        expected = <<-EOF.strip
{
  "run_list": [
    "role[cloudname]"
  ]
}
        EOF
        assert_equal expected, result
      ensure
        dnafile.close
        dnafile.unlink
      end

      rolefile = nil

      begin
        rolefile = Tempfile.new("cloudname.json")

        client.send(:write_chef_role_json, rolefile.path)

        rolefile.rewind
        result = rolefile.read
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
      "parent_name": "test",
      "name": "chefcloud",
      "pool_info": {
        "clouds": {

        }
      }
    }
  },
  "chef_type": "role",
  "description": "PoolParty cloud",
  "name": "chefcloud"
}
        EOF
        assert_equal JSON.parse(expected, :create_additions => false), JSON.parse(result, :create_additions => false)
      ensure
        rolefile.close
        rolefile.unlink
      end
    end
  end
end
