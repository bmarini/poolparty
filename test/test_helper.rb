require "rubygems"
require "bundler/setup"
require "test/unit"
require "shoulda"
require "mocha"
require "tempfile"
require "test_methods"

modify_env_with_hash(
  "EC2_ACCESS_KEY"  => "fake_access_key",
  "EC2_SECRET_KEY"  => "fake_secret_key",
  "EC2_PRIVATE_KEY" => ::File.dirname(__FILE__) + "/fixtures/keys/test_key",
  "EC2_CERT"        => ::File.dirname(__FILE__) + "/fixtures/keys/test_key",
  "EC2_USER_ID"     => '1234567890'
)

require "poolparty"
require "git-style-binary/command"
GitStyleBinary.run = true

# Helper methods
class Test::Unit::TestCase
  def assert_equal_files(file1, file2)
    if File.extname(file1) == ".json"
      assert_equal(
        JSON.parse(File.read(file1), :create_additions => false),
        JSON.parse(File.read(file2), :create_additions => false)
      )
    else
      assert_equal( File.read(file1), File.read(file2), "Expected #{file1} to be equal to #{file2}: %s" )
    end
  end
end