require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class ProvidersControllerTest < Test::Unit::TestCase
  context "POST to providers" do
    context "with valid parameters" do
      setup do
        post app.url(:providers), :providers_form => options
        follow_redirect!
        @job = ProvidersJob.last
      end

      should_create_the_job      
    end

    context "without valid parameters" do
      setup { post app.url(:providers) }     
      should_return_success
    end
  end

  context "GET to providers" do
    setup { get app.url(:providers) }
    should_return_success
  end
end
