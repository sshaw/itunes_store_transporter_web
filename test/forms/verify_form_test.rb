require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class VerifyFormTest < Minitest::Test
  should_require_a_package
  should_behave_like_a_job_form
  should validate_presence_of :package
end
