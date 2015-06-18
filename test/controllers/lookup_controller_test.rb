require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class LookupControllerTest < CapybaraTestCase
  should_toggle_auth_fields(app.url(:lookup))

  context "POST to status" do
    context "with valid parameters" do
      setup do
        @options = options.merge(:package_id => "vendor_id", :package_id_value => "VID")
        post app.url(:lookup), :lookup_form => @options
        follow_redirect!
        @job = LookupJob.last
      end

      should "create the job" do
        refute_nil @job, "job created"
      end

      should "set the job's options" do
        assert_equal options.merge(:vendor_id => "VID"), @job.options
      end

      should_create_the_job
    end

    context "without valid parameters" do
      setup { post app.url(:lookup) }
      should_return_success
    end
  end

  context "GET to lookup" do
    setup { get app.url(:lookup) }
    should_return_success
  end
end
