require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class VerifyControllerTest < CapybaraTestCase
  should_toggle_auth_fields(app.url(:verify))

  context "POST to verify" do
    context "with valid parameters" do
      setup do
        @options = options.merge(:package => "package.itmsp", :verify_assets => true)
        post app.url(:verify), :verify_form => @options
        follow_redirect!
        @job = VerifyJob.last
      end

      should "set the job's options" do
        assert_equal @options, @job.options
      end

      should_create_the_job
    end

    context "without valid parameters" do
      setup { post app.url(:verify) }
      should_return_success
    end
  end

  context "GET to verify" do
    setup { get app.url(:verify) }
    should_return_success
  end
end
