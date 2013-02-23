require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class StatusFormTest < Test::Unit::TestCase
  should validate_presence_of :vendor_id
end
