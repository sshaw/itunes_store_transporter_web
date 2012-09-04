require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class ProvidersControllerTest < CapybaraTestCase
  context "listing providers" do
    context "a valid submission" do
      setup do
        visit "/providers"
        fill_in_auth
        click_button "List Providers"

        @job = ProvidersJob.last
      end

      should_create_the_job
      
      [:username, :password, :shortname].each do |opt|
        should "set the #{opt} option" do
          assert_equal options[opt], @job.options[opt]
        end
      end
    end
  end
end
