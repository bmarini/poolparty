require "test_helper"
stub_ec2_calls

class CloudTest < Test::Unit::TestCase
  def setup
    cloudfile = "#{fixtures_dir}/clouds/simple_cloud.rb"
    @pools    = PoolParty::Dsl.load(cloudfile)
    @cloud    = @pools.first.clouds.first
  end

  def test_have_a_pool_name
    assert_equal @pools.first.name, @cloud.pool.name
  end

  def test_have_a_keypair
    assert_not_nil @cloud.keypair
    assert_equal 'test_key', @cloud.keypair.basename
  end

  def test_be_using_ec2_cloud_provider_by_default
    assert_equal :ec2, @cloud.cloud_provider.name
    assert_kind_of ::CloudProviders::Ec2, @cloud.cloud_provider
  end

  def test_set_the_cloud_provider_cloud_and_keypair_with_cloud_provider
    assert_equal @cloud, @cloud.cloud_provider.cloud
    assert_equal @cloud.keypair.basename, @cloud.cloud_provider.keypair.basename
  end

  def test_set_the_cloud_provider_with_a_using_block
    @cloud.provider = :ec2
    @cloud.keypair  = "test_key", "#{fixtures_dir}/keys"
    @cloud.image_id 'emi-39921602'

    assert_equal :ec2, @cloud.cloud_provider.name
    assert_equal CloudProviders::Ec2, @cloud.cloud_provider.class
    assert_equal "emi-39921602", @cloud.cloud_provider.image_id
  end

  def test_nodes
    assert_respond_to @cloud, :nodes
    assert_respond_to @cloud.nodes, :each
    assert_equal 0, @cloud.nodes.size
  end

  def test_run
    # WHAT?
    # result = @cloud.run('uptime')
    # assert_match /uptime/, result["app"]
  end

  def test_expansion
    #TODO: improve this test
    # size = @cloud.nodes.size
    # assert_equal size+1, @cloud.expand.nodes.size
    # assert_nothing_raised @cloud.expand
  end

  def test_contract!
    #TODO: need to better mock the terminate! ec2 call
    # size = @cloud.nodes.size
    # result = @cloud.contract!
    # assert_equal 'shuttin-down',  result.status
    # assert_equal size-1, @cloud.nodes.size
  end

  def test_change_ssh_port
    pools = PoolParty::Dsl.evaluate <<-EOF
      pool "ssh_port" do
        cloud "babity" do
          using :ec2
          keypair "test_key"
          ssh_port 1922
        end
      end
    EOF

    assert_equal 1922, pools.first.clouds["babity"].ssh_port
    assert_equal 22, pools.first.clouds["noneity"].ssh_port
  end

  def test_change_ssh_port
    pools = PoolParty::Dsl.evaluate <<-EOF
      pool "ssher" do
        cloud "custom" do
          using :ec2
          keypair "test_key"
          # ssh_options("-P" => "1992")
        end
        cloud "noneity" do
          using :ec2
          keypair "test_key"
        end
      end
    EOF

    # assert_equal "1992", clouds["custom"].ssh_options["-P"]
  end
end