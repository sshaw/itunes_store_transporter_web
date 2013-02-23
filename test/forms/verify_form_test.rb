require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class VerifyFormTest < Test::Unit::TestCase
  should validate_presence_of :package
  should allow_value("123.itmsp").for(:package)
  should_not allow_value("123", "123.itms").for(:package)
end
