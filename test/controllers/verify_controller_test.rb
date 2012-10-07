require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class VerifyControllerTest < CapybaraTestCase  
  context "verifying a package" do    
    context "the package" do
      setup { visit app.url(:verify) }

      should_eventually "have a file dialog" do
        click_on "Select Package"
      end
      
      should "be required" do
        click_button "Verify"
        assert package_blank?
      end
      
      should "end in .itmsp" do
        fill_in_package("some_thang")
        click_button "Verify"
        assert package_name_invalid?
      end
    end
    
    context "with default settings" do 
      setup do 
        @config = set_defaults
        visit app.url(:verify)
      end
      
      [:username, :password, :shortname].each do |opt|
        should "set the #{opt} field to the default" do
          assert_equal @config[opt].to_s, find_field("verify_form[#{opt}]").value
        end
      end
    end
  
    context "with all the required fields" do      
      setup do 
        @options = options.merge(:package => "package.itmsp", :verify_assets => true)
        
        visit app.url(:verify) 
        fill_in_package @options[:package]
        check "Verify assets"
        click_button "Verify"
        
        @job = VerifyJob.last
      end
      
      should_create_the_job
      
      [:username, :password, :shortname, :package, :verify_assets].each do |opt|
        should "set the job's #{opt} option" do    
          assert_equal @options[opt], @job.options[opt]
        end
      end
    end    
  end
end

