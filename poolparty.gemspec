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

  s.files            = %w(Rakefile README.rdoc License.txt VERSION.yml) + Dir["{config,examples,lib,test,tasks,script,generators,bin,vendor}/**/*"]
  s.test_files       = Dir["test/**/test_*.rb"]
  s.executables      = Dir["bin/*"]
  s.require_paths    = ["lib"]

  s.rdoc_options     = ["--quiet", "--title", "PoolParty documentation", "--line-numbers", "--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
end

