require "rubygems"
require "bundler/setup"
require "test/unit"
require "shoulda"
require "mocha"

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
