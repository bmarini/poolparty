require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'config/requirements'

begin
  require 'hanna/rdoctask'
rescue LoadError => e
  require "rake/rdoctask"
end

task :default  => [:test, :cleanup_test]
desc "Update vendor directory and run tests"

task :cleanup_test do
  ::FileUtils.rm_rf "/tmp/poolparty"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/{lib,unit}/**/*_test.rb']
  t.warning = false
  t.verbose = true
end

desc 'Measures test coverage'
task :coverage do
  rm_f "coverage"
  rm_f "coverage.data"
  system "rcov -x /Users -Ilib:test #{FileList['test/{lib,unit}/**/*_test.rb']}"
  system "open coverage/index.html" if PLATFORM['darwin']
end

desc "Clean tmp directory"
task :clean_tmp do |t|
  FileUtils.rm_rf("#{File.dirname(__FILE__)}/Manifest.txt") if ::File.exists?("#{File.dirname(__FILE__)}/Manifest.txt")
  FileUtils.touch("#{File.dirname(__FILE__)}/Manifest.txt")
  %w(logs tmp).each do |dir|
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/#{dir}") if ::File.exists?("#{File.dirname(__FILE__)}/#{dir}")
  end
end

desc "Remove the pkg directory"
task :clean_pkg do |t|
  %w(pkg).each do |dir|
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/#{dir}") if ::File.exists?("#{File.dirname(__FILE__)}/#{dir}")
  end
end


namespace :gem do
  task(:build).prerequisites.unshift :gemspec # Prepend the gemspec generation

  desc "Build the gem only if the tests pass"
  task :test_then_build => [:test, :build]

  desc "Build and install the gem only if the tests pass"
  task :test_then_install => [:test, :install]
end

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
  # rd.template = "hanaa"
end
