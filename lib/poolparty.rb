# Load system gems
require 'logger'
require 'erb'
require 'open-uri'

# Add all vendor gems to the load paths
Dir[File.dirname(__FILE__)+"/../vendor/gems/*"].each do |lib|
  $:.unshift( File.expand_path("#{lib}/lib") )
end

# Load local gems
%w(dslify json searchable_paths).each do |dep|
  require dep
end

module PoolParty
  autoload :Base, "poolparty/base"
  autoload :Chef, "poolparty/chef"
  autoload :ChefAttribute, "poolparty/chef_attribute"
  autoload :ChefClient, "poolparty/chef_client"
  autoload :ChefDnaFile, "poolparty/chef_dna_file"
  autoload :ChefSolo, "poolparty/chef_solo"
  autoload :Cloud, "poolparty/cloud"
  autoload :Dsl, "poolparty/dsl"
  autoload :Pool, "poolparty/pool"
  autoload :PoolPartyError, "poolparty/pool_party_error"
  autoload :VERSION, "poolparty/version"

  def self.version
    VERSION
  end

  def self.lib_dir
    File.join(File.dirname(__FILE__), "..")
  end
end

# Core object overloads
%w( object string array hash symbol ).each do |lib|
  require "core/#{lib}"
end

require 'keypair'
require 'cloud_providers'
