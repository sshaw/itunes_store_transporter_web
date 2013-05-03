require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class SchemaControllerTest < CapybaraTestCase
  should_toggle_auth_fields(app.url(:schema))
  
  context "POST to schema" do
    context "with valid parameters" do
      setup do
        post app.url(:schema), :schema_form => options.merge(:type => "strict", :version_name => "film", :version_number => "5.0")
        follow_redirect!
        @job = SchemaJob.last
      end

      should "set the job's options" do
        assert_equal options.merge(:type => "strict", :version => "film5.0"), @job.options
      end

      should_create_the_job
    end

    context "without valid parameters" do
      setup { post app.url(:schema) }     
      should_return_success      
    end
  end
  
  context "GET to schema" do
    setup { get app.url(:schema) }
    should_return_success
  end
end
