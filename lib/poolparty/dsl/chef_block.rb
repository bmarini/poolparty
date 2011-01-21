module PoolParty
  module Dsl
    class ChefBlock

      def self.evaluate(type, cloud, &block)
        klass   = type == :solo ? ChefSoloBlock : ChefClientBlock
        builder = klass.new(cloud)
        builder.instance_eval(&block)
        builder.to_definition
      end

      def recipe(recipe_name, atts={})
        @chef.add_recipe(recipe_name, @action.last, atts)
      end

      def recipes(*recipe_names)
        recipe_names.each { |r| recipe(r) }
      end

      def attributes(atts)
        @chef.attributes = atts
      end

      def override_attributes(atts)
        @chef.override_attributes = atts
      end

      # === Description
      #
      # Provides the ability to specify steps that can be
      # run via chef
      #
      # pool "mycluster" do
      #   cloud "mycloud" do
      #       
      #       on_step :download_install do
      #           recipe "myrecipes::download"
      #           recipe "myrecipes::install"
      #       end
      #
      #       on_step :run => :download_install do
      #           recipe "myrecipes::run"
      #       end
      #   end
      # end
      #
      # Then from the command line you can do
      #
      # cloud-configure --step=download_install 
      #
      # to only do the partial job or
      #
      # cloud-configure --step=run
      #
      # to do everything
      def on_step(action)
        if action.is_a?(Hash)
          action, depends = action.shift
        else
          depends = nil
        end

        @action.push(action)
        @chef.recipes(depends).each { |r| recipe(r) } if depends

        begin
          yield if block_given?
        ensure
          @action.pop
        end
      end

      def to_definition
        @chef
      end
    end

    class ChefSoloBlock < ChefBlock
      def initialize(cloud)
        @chef = ChefSolo.new(cloud)
        @action = [:default]
      end

      def repo(name)
        @chef.repo = name
      end
    end

    class ChefClientBlock < ChefBlock
      def initialize(cloud)
        @chef = ChefClient.new(cloud)
        @action = [:default]
      end

      def server_url(server_url)
        @chef.server_url = server_url
      end

      def openid_url(openid_url)
        @chef.openid_url = openid_url
      end

      def validation_token(validation_token)
        @chef.validation_token = validation_token
      end

      def validation_key(validation_key)
        @chef.validation_key = validation_key
      end

      def validation_client_name(validation_client_name)
        @chef.validation_client_name = validation_client_name
      end

      def init_style(init_style)
        @chef.init_style = init_style
      end

      def roles(*roles)
        @chef.roles = roles
      end
    end
  end
end