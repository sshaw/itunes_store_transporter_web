require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class StatusControllerTest < CapybaraTestCase
  context "looking up a job's status" do 

    should "require a vendor id" do 
      visit app.url(:status)
      click_button "Check Status"
      assert has_content?("Vendor ID can't be blank")
    end
    
    context "a valid submission" do
      setup do
        # apple_id too
        @options = options.merge(:vendor_id => "VID")
        visit "/status"
        fill_in_auth
        fill_in "Vendor ID", :with => @options[:vendor_id]
        click_button "Check Status"
        
        @job = StatusJob.last
      end

      should_create_the_job
      
      [:username, :password, :shortname, :vendor_id].each do |opt|
        should "set the #{opt} option" do    
          assert_equal @options[opt], @job.options[opt]
        end
      end
    end    
  end
end

