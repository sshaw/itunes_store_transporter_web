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
      assert AppConfig.new.path.present?
    end
  end
end
