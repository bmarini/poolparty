module PoolParty
  class Chef
    attr_reader :cloud, :attributes, :override_attributes

    BOOTSTRAP_PACKAGES = %w( ruby ruby1.8-dev libopenssl-ruby1.8 rdoc
      ri irb build-essential wget ssl-cert rubygems git-core rake
      librspec-ruby libxml-ruby zlib1g-dev libxml2-dev )
    # thin couchdb 
    BOOTSTRAP_GEMS = %w( chef )

    # we dont specifically install these binaries, they installed by
    # packages and gems above, but we check for them
    BOOTSTRAP_BINS = %w( gem chef-solo chef-client )
    BOOTSTRAP_DIRS = %w( /var/log/chef /var/cache/chef /var/run/chef )

    def attributes
      @attributes ||= ChefAttribute.new
    end
    
    def override_attributes
      @override_attributes ||= ChefAttribute.new
    end

    def attributes=(atts)
      @attributes = ChefAttribute[atts]
    end
    
    def override_attributes=(atts)
      @override_attributes = ChefAttribute[atts]
    end

    def add_recipe(recipe_name, action=:default, recipe_atts={})
      _recipes(action) << recipe_name unless _recipes(action).include?(recipe_name)

      unless recipe_atts.empty?
        key = recipe_name.split("::").first
        override_attributes.merge!(key => recipe_atts)
      end
    end

    def recipes(*recipes)
      recipes.each do |r|
        add_recipe(r)
      end
    end

    def compile!
      build_tmp_dir
    end

    def node_run!(remote_instance)
      node_stop!(remote_instance)
      node_configure!(remote_instance)

      envhash = {
        :GEM_BIN => %q%$(gem env | grep "EXECUTABLE DIRECTORY" | awk "{print \\$4}")%
      }
      cmds = chef_cmd
      cmds = [cmds] unless cmds.respond_to? :each

      remote_instance.ssh(cmds.map{|c| c.strip.squeeze(' ')}, :env => envhash )
    end

    def node_stop!(remote_instance)
      remote_instance.ssh("killall -q chef-client chef-solo; [ -f /etc/init.d/chef-client ] && invoke-rc.d chef-client stop")
    end

    def node_configure!(remote_instance)
      # nothing in the superclass
    end

    def node_bootstrapped?(remote_instance, quiet=true)
      # using which command instead of calling gem directly.  On
      # ubuntu, calling a command from package not installed
      # 'helpfully' prints message, which result confuses detection
      #
      cmd = "which %s" % BOOTSTRAP_BINS.join(' ') +
        " && dpkg -l %s " % BOOTSTRAP_PACKAGES.join(' ') +
        BOOTSTRAP_GEMS.map{ |gem|
          "&& gem search '^#{gem}$' | grep -v GEMS | wc -l | grep -q 1"
        }.join(' ') +
        BOOTSTRAP_DIRS.map{ |dir|
          "&& [[ -d #{dir} ]] "
        }.join(' ') +
        (quiet ? " >/dev/null " : "" ) +
        " && echo OK || echo MISSING"

      r = remote_instance.ssh(cmd, :do_sudo => false )
      r.split("\n").to_a.last.chomp == "OK"
    end

    def node_bootstrap!(remote_instance, force=false)
      return if !force && node_bootstrapped?(remote_instance)

      # TODO: this should not be hardcoded (like in node_run)
      deb_gem_bin='/var/lib/gems/1.8/bin'
      gem_src='http://gems.opscode.com'

      bootstrap_cmds =
        [
         'apt-get update',
         'apt-get autoremove -y',
         'apt-get install -y %s' % BOOTSTRAP_PACKAGES.join(' '),
         "gem source -l | grep -q #{gem_src} || gem source -a #{gem_src} ",
         'gem install %s --no-rdoc --no-ri' % 
            (BOOTSTRAP_GEMS + remote_instance.bootstrap_gems).join(' '),
         "apt-get install -y %s" % BOOTSTRAP_PACKAGES.join(' '),
         "[ -d #{deb_gem_bin} ] && ln -sf #{deb_gem_bin}/* /usr/local/bin",
         "mkdir -p %s" % BOOTSTRAP_DIRS.join(' ')
        ]

      remote_instance.ssh(bootstrap_cmds)
      end

    def _recipes(action=nil)
      @recipes ||= Hash.new { |h,k| h[k] = [] }

      action = action.to_sym unless action.nil?
      key = action || current_action

      @recipes[key]
    end

    private

    def current_action
      @current_action ||= :default
    end

    def chef_cmd

      if ENV["CHEF_DEBUG"]
        debug = "-l debug"
      else
        debug = ""
      end

      return <<-CMD
        PATH="$PATH:$GEM_BIN" #{chef_bin} -j /etc/chef/dna.json -c /etc/chef/client.rb -d -i 1800 -s 20 #{debug}
      CMD
    end

  end
end
