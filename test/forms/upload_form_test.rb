require "options"
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class UploadFormTest < Test::Unit::TestCase
  should allow_value(1,100_000_000).for(:rate)
  should_not allow_value(-1.5, -1, 0, 1.5).for(:rate)
  should ensure_inclusion_of(:transport).in_array(Options::TRANSPORTS)
end
