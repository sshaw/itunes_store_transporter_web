require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class UploadControllerTest < CapybaraTestCase
  should_toggle_auth_fields(app.url(:upload))

  context "POST to upload" do
    context "with valid parameters" do
      setup do
        @options = options.merge(:package => "crap.itmsp", :delete => false)
        post app.url(:upload), :upload_form => @options
        follow_redirect!
        @job = UploadJob.last
      end

      should "create the job" do
        assert_not_nil @job, "job created"
      end
      
      should "set the job's options" do
        assert_equal @options, @job.options
      end
      
      should_create_the_job
    end
    
    context "without valid parameters" do
      setup { post app.url(:upload) }
      should_return_success      
    end
  end
  
  context "GET to upload" do
    setup { get app.url(:upload) }
    should_return_success
  end

  context "with default settings" do
    setup do
      @options = set_defaults(options.merge(:rate => 100, :transport => "Signiant"))
      visit app.url(:upload)
    end
    
    [:rate, :transport, :username, :password, :shortname].each do |opt|
      should "set the #{opt} field to the default" do
        # :rate is an int
        assert_equal @options[opt].to_s, find_field("upload_form[#{opt}]").value
      end
    end
  end
end
