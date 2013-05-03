require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class StatusControllerTest < CapybaraTestCase
  should_toggle_auth_fields(app.url(:status))
  
  context "POST to status" do
    context "with valid parameters" do
      setup do
        @options = options.merge(:vendor_id => "VID")
        post app.url(:status), :status_form => @options
        follow_redirect!
        @job = StatusJob.last
      end

      should "set the job's options" do
        assert_not_nil @job, "job created"
        assert_equal @options, @job.options
      end
      
      should_create_the_job
    end

    context "without valid parameters" do
      setup { post app.url(:status) }
      should_return_success
    end
  end

  context "GET to status" do
    setup { get app.url(:status) }
    should_return_success
  end
end
