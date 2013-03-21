require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class StatusFormTest < Test::Unit::TestCase
  should_behave_like_a_job_form
  should validate_presence_of(:vendor_id).with_message("ID can't be blank")
end
