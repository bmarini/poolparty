require 'uri' # for URI.parse in write_bootstrap_files

module PoolParty
  # Chef class bootstrapping chef-client.
  class ChefClient < Chef
    attr_accessor :server_url, :validation_token, :validation_key, :validation_client_name, :init_style

    def initialize(cloud)
      @cloud = cloud
      @roles = [ @cloud.name ]
    end

    def openid_url=(url)
      @openid_url = url
    end

    def openid_url
      @openid_url ||= begin
        u = URI.parse(server_url)
        u.port = 4001
        u.to_s
      end
    end

    def roles=(roles)
      @roles = Array(roles)
    end

    def roles
      @roles
    end

    def run_list
      list = roles.map { |r| "role[#{r}]" } +  _recipes.map { |r| "recipe[#{r}]" }
      return { :run_list => list }
    end

    private

    def chef_bin
      "chef-client"
    end

    # When init_style.nil?, old behavior is used (just run the client).
    # If init_style is specified, bootstrap::client cookbook is executed
    # To this init style.
    def chef_cmd
      # without init_style, let parent class start chef-client
      return super unless init_style

      'invoke-rc.d chef-client start'
    end

    def node_configure!(remote_instance)
      super
      cmds =
        [ 'PATH="$PATH:$GEM_BIN" chef-solo -j /tmp/chef/chef.json -c /tmp/chef/solo.rb',
          'invoke-rc.d chef-client stop',
          'PATH="$PATH:$GEM_BIN" chef-client -j /etc/chef/dna.json -c /etc/chef/client.rb',
        ]

      remote_instance.ssh cmds
    end

    def build_tmp_dir(tmp_path)
      TempDir.new(tmp_path, self).build
    end

    class TempDir
      def initialize(tmp_path, chef)
        @tmp_path = tmp_path
        @chef     = chef
      end

      def build
        make_base_dir

        write_validation_key_file
        write_attribute_file

        if original_init_style?
          write_config_file
        else
          make_bootstrap_dir
          write_bootstrap_config_file
          write_bootstrap_attribute_file
        end
      end

      def make_base_dir
        FileUtils.rm_rf base_dir
        FileUtils.mkdir_p base_dir
      end

      def write_validation_key_file
        FileUtils.cp @chef.validation_key, base_dir if @chef.validation_key
      end

      def write_config_file
        content = <<-EOE
log_level          :info
log_location       "/var/log/chef/client.log"
ssl_verify_mode    :verify_none
file_cache_path    "/var/cache/chef"
pid_file           "/var/run/chef/client.pid"
Chef::Log::Formatter.show_time = true
openid_url         "#{@chef.openid_url}"
chef_server_url    "#{@chef.server_url}"
        EOE

        content += %Q{validation_token  "#{@chef.validation_token}"\n} if @chef.validation_token
        content += %Q{validation_key    "/etc/chef/#{File.basename @chef.validation_key}"\n} if @chef.validation_key
        content += %Q{validation_client_name  "#{@chef.validation_client_name}"\n} if @chef.validation_client_name

        File.open("#{base_dir}/client.rb", "w") do |f|
          f << content
        end
      end

      def write_attribute_file
        ChefDnaFile.to_dna( [], "#{base_dir}/dna.json", dna_hash )
      end

      def dna_hash
        @chef.run_list.merge(@chef.attributes)
      end

      def make_bootstrap_dir
        FileUtils.rm_rf bootstrap_dir
        FileUtils.mkdir_p bootstrap_dir
      end

      def write_bootstrap_config_file
        content = <<-EOF
file_cache_path "/tmp/chef-solo"
cookbook_path "/tmp/chef-solo/cookbooks"
recipe_url "http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz"
        EOF

        File.open("#{bootstrap_dir}/solo.rb", "w") { |f| f << content }
      end

      def write_bootstrap_attribute_file
        uri = URI.parse(@chef.server_url)
        # this maybe reduntant, URL should have a port in there
        uri.port = 4000 if uri.port == 80 # default port for chef

        bootstrap_json = {
          :bootstrap => {
            :chef => {
              :url_type =>  uri.scheme,
              :init_style => @chef.init_style,
              :path => "/srv/chef",
              :serve_path => "/srv/chef",
              :server_fqdn => uri.host + uri.path,
              :server_port => uri.port,
            }
          },
          :run_list => [ 'recipe[bootstrap::client]' ]
        }

        if @chef.validation_client_name
          bootstrap_json[:bootstrap][:chef][:validation_client_name] = @chef.validation_client_name
        end

        ChefDnaFile.to_dna([], "#{bootstrap_dir}/chef.json", bootstrap_json)
      end

      def base_dir
        "#{@tmp_path}/etc/chef"
      end

      def bootstrap_dir
        "#{@tmp_path}/tmp/chef"
      end

      def original_init_style?
        @chef.init_style.nil?
      end
    end
  end
end
