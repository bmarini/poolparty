# CloudProvider is the base class for cloud computing services such as Ec2,
# Eucalyptus - where your servers run.
module CloudProviders
  autoload :CloudProvider, "cloud_providers/cloud_provider"
  autoload :Connections, "cloud_providers/connections"
  autoload :RemoteInstance, "cloud_providers/remote_instance"
  autoload :Ec2, "cloud_providers/ec2/ec2"

  def self.all
    @all ||= []
  end
end
