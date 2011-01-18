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
        @chef.recipe(recipe_name, atts)
      end

      def recipes(*recipe_names)
        @chef.recipes(*recipe_names)
      end

      def attributes(atts)
        @chef.attributes = atts
      end

      def override_attributes(atts)
        @chef.override_attributes = atts
      end

      def on_step(action, &block)
        @chef.on_step(action, &block)
      end

      def to_definition
        @chef
      end
    end

    class ChefSoloBlock < ChefBlock
      def initialize(cloud)
        @chef = ChefSolo.new(:solo, :cloud => cloud)
      end

      def repo(name)
        @chef.repo(name)
      end
    end

    class ChefClientBlock < ChefBlock
      def initialize(cloud)
        @chef = ChefClient.new(:client, :cloud => cloud)
      end

      def server_url(server_url)
        @chef.server_url server_url
      end

      def openid_url(openid_url)
        @chef.openid_url(openid_url)
      end

      def validation_token(validation_token)
        @chef.validation_token validation_token
      end

      def validation_key(validation_key)
        @chef.validation_key validation_key
      end

      def validation_client_name(validation_client_name)
        @chef.validation_client_name validation_client_name
      end

      def init_style(init_style)
        @chef.init_style init_style
      end

      def roles(*roles)
        @chef.roles(*roles)
      end
    end
  end
end