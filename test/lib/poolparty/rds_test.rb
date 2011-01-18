require "test_helper"
stub_ec2_calls

class RdsTest < Test::Unit::TestCase
  def setup
    stub_response(AWS::EC2::Base, :describe_security_groups, 'ec2-describe-security-groups')
    stub_response(AWS::EC2::Base, :run_instances,            'ec2-run-instances')
    stub_response(AWS::RDS::Base, :describe_db_instances,    'rds-describe-db-instances-empty')
  end

  # def test_stubs
  #   assert_equal "", AWS::RDS::Base.new(
  #     :access_key_id => ENV['EC2_ACCESS_KEY'],
  #     :secret_access_key => ENV['EC2_SECRET_KEY']
  #   ).describe_db_instances
  # end

  def test_basic
    # scenario "rds_cloud"
  end

  def test_required_properties
    assert_raises(RuntimeError) { scenario "rds_missing_params" }
  end

  private

  def scenario(filename)
    filepath = "#{fixtures_dir}/clouds/#{filename}.rb"
    pools    = PoolParty::Dsl.load(filepath)
    @cloud   = pools.first.clouds.values.first
    @cloud.run
  end

  def stub_response(klass, method, fixture_filename)
    klass.any_instance.stubs(method).returns AWS::Response.parse(:xml => open(fixtures_dir/"ec2/#{fixture_filename}_response_body.xml").read)
  end
end