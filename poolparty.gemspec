$:.push File.expand_path("../lib", __FILE__)
require "poolparty/version"

Gem::Specification.new do |s|
  s.name             = "poolparty"
  s.version          = PoolParty::VERSION
  s.platform         = Gem::Platform::RUBY

  s.homepage         = "http://poolpartyrb.com"
  s.authors          = ["Ari Lerner", "Michael Fairchild", "Nate Murray"]
  s.email            = "arilerner@mac.com"
  s.description      = "PoolParty: The easy, open-source, cross-cloud management solution"
  s.summary          = <<-EOM
    Self-healing, auto-scaling system administration, provisioning
    and maintaining tool that makes cloud computing easier.
  EOM

  s.add_dependency "amazon-ec2", "~> 0.9.9"
  s.add_development_dependency "shoulda", "~> 2.11.2"
  s.add_development_dependency "mocha", "~> 0.9.10"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_development_dependency "rcov", "~> 0.9.9"

  s.files            = %w(Rakefile README.rdoc License.txt VERSION.yml) + Dir["{config,examples,lib,test,tasks,script,generators,bin,vendor}/**/*"]
  s.test_files       = Dir["test/**/test_*.rb"]
  s.executables      = Dir["bin/*"].map { |f| File.basename(f) }
  s.require_paths    = ["lib"]

  s.rdoc_options     = ["--quiet", "--title", "PoolParty documentation", "--line-numbers", "--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
end

