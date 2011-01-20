
module PoolParty
  class ChefSolo < Chef
    attr_accessor :repo

    def initialize(cloud)
      @cloud = cloud
    end

    private

    def chef_bin
      "chef-solo"
    end

    def chef_cmd

      if ENV["CHEF_DEBUG"]
        debug = "-l debug"
      else
        debug = ""
      end

      return <<-CMD
        PATH="$PATH:$GEM_BIN" #{chef_bin} -j /etc/chef/dna.json -c /etc/chef/solo.rb #{debug}
      CMD
    end

    def build_tmp_dir(tmp_path)
      TempDir.new(tmp_path, self).build
    end

    # This class builds a local temp directory that will get rsynced to the
    # nodes This temp directory will contain configuration files needed for
    # chef to run

    require "fileutils"

    class TempDir
      # Minimal stuff to run chef-solo
      # ------------------------------
      #
      # Cookbooks will need to by uploaded to the `cookbook_path`
      #
      # Command to run:
      # $ chef-solo -c etc/chef/solo.rb -j etc/chef/node.json

      # -- /etc/chef/solo.rb --
      #
      # file_cache_path "/etc/chef"
      # cookbook_path "/etc/chef/cookbooks"
      # role_path "/etc/chef/roles"

      # -- /etc/chef/node.json --
      #
      # { "run_list": "role[test]" }

      # -- /etc/chef/roles/test.json --
      #
      # {
      #   "name": "test",
      #   "default_attributes": { },
      #   "override_attributes": { },
      #   "json_class": "Chef::Role",
      #   "description": "This is just a test role, no big deal.",
      #   "chef_type": "role",
      #   "run_list": [ "recipe[test]" ]
      # }

      attr_accessor :config_filename, :attribute_filename

      def initialize(tmp_path, chef)
        @tmp_path           = tmp_path
        @chef               = chef
        @config_filename    = "solo.rb"
        @attribute_filename = "dna.json"
      end

      def build
        raise "#{@chef.repo} chef-repo directory does not exist" unless File.directory?(@chef.repo)

        make_directories
        copy_cookbooks
        write_config_file
        write_attribute_file
        write_role_file
      end

      def make_directories
        # puts "Copying the chef-repo from #{@chef.repo} to #{tmp_chef_path}"
        FileUtils.rm_rf   tmp_chef_path
        FileUtils.mkdir_p tmp_chef_path
        FileUtils.mkdir_p tmp_roles_path
      end

      def copy_cookbooks
        FileUtils.mkdir_p tmp_cookbook_path
        FileUtils.cp_r    "#{@chef.repo}/.", tmp_cookbook_path
      end

      def write_attribute_file
        path = File.join tmp_chef_path, @attribute_filename
        ChefDnaFile.to_dna([], path, dna_hash)
      end

      def write_config_file
        path = File.join tmp_chef_path, @config_filename
        content = <<-EOE
cookbook_path     ["/etc/chef/cookbooks/cookbooks", "/etc/chef/cookbooks/site-cookbooks"]
role_path         "/etc/chef/roles"
log_level         :info
        EOE

        File.open(path, "w") { |f| f << content }
      end

      def write_role_file
        path = File.join tmp_roles_path, "#{role}.json"
        ChefDnaFile.to_dna(role_recipes, path, role_hash)
      end

      def tmp_chef_path
        File.join @tmp_path, "etc/chef"
      end

      def tmp_roles_path
        File.join tmp_chef_path, "roles"
      end

      def tmp_cookbook_path
        File.join tmp_chef_path, "cookbooks"
      end

      def cloud
        @chef.cloud
      end

      def role
        cloud.name
      end

      def role_recipes
        @chef._recipes(cloud.pool.chef_step).map { |a| File.basename(a) }
      end

      def dna_hash
        { :run_list => ["role[#{role}]"] }
      end

      def role_hash
        # Add the parent name and the name of the cloud to
        # the role for easy access in recipes.
        pool_party_attributes = {
          :poolparty => {
            :parent_name => cloud.pool.name,
            :name => cloud.name,
            :pool_info => cloud.pool.to_hash
          }
        }

        override_attributes = @chef.override_attributes.merge(pool_party_attributes)

        return {
          :name => role,
          :json_class => "Chef::Role",
          :chef_type => "role",
          :default_attributes => @chef.attributes,
          :override_attributes => override_attributes,
          :description => cloud.description
        }
      end
    end

  end
end
