require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
require "options"

class AppConfigTest < Test::Unit::TestCase
  should validate_numericality_of(:rate)
  should_not allow_value(0).for(:rate)
  should_not allow_value(-1).for(:rate)

  Options::TRANSPORTS.each do |opt|
    should allow_value(opt).for(:transport)
  end

  context "#path" do
    should "have a default" do
      assert !AppConfig.new.path.empty?
    end
  end

  context "#instance" do
    setup { @config = AppConfig.instance }

    should "return an instance of AppConfig" do
      assert_kind_of AppConfig, @config
    end

    should "always return the same instance" do
      assert_equal AppConfig.instance, AppConfig.instance
    end
  end
end
