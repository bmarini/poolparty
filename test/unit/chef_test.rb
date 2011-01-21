require "test_helper"

class ChefTest < Test::Unit::TestCase
  context "Chef" do
    should "have attributes" do
      assert_instance_of Hash, PoolParty::ChefSolo.new(nil).attributes
      assert_instance_of Hash, PoolParty::ChefSolo.new(nil).override_attributes
    end
  end

  context "Chef DSL" do
    should "support recipes" do
      pools = PoolParty::Dsl.evaluate <<-EOF
        pool do
          cloud "proj" do
            using :ec2
            chef :solo do
              recipes "apache2", "varnish"
            end
          end
        end
      EOF

      chef = pools.first.clouds.first.chef
      assert_equal ["apache2", "varnish"], chef.recipes
    end

    # on_step :download_install do
    #     recipe "myrecipes::download"
    #     recipe "myrecipes::install"
    # end
    #
    # on_step :run => :download_install do
    #     recipe "myrecipes::run"
    # end

    should "support on_step" do
      pools = PoolParty::Dsl.evaluate <<-EOF
        pool do
          cloud "proj" do
            using :ec2
            chef :solo do
              on_step :download_install do
                  recipe "myrecipes::download"
                  recipe "myrecipes::install"
              end

              on_step :run => :download_install do
                  recipe "myrecipes::run"
              end
            end
          end
        end
      EOF

      chef = pools.first.clouds.first.chef
      assert_equal [], chef.recipes
      assert_equal ["myrecipes::download", "myrecipes::install"], chef.recipes(:download_install)

      assert_equal ["myrecipes::download", "myrecipes::install", "myrecipes::run"], chef.recipes(:run)
    end
  end
end