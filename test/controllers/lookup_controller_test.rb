require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class LookupControllerTest < CapybaraTestCase
  context "looking up metadata" do 
    context "the identifier field" do
      setup { visit app.url(:lookup) }
      
      should "be required" do
        click_button "Lookup"
        assert has_content?("You must provide an Apple ID or Vendor ID")
      end

      should "have the right ID options" do
        assert has_select?("lookup_form[package_id]", :options => ["Apple ID", "Vendor ID"]), "option text" 
        assert has_selector?("select option[value=apple_id]"), "apple_id value"
        assert has_selector?("select option[value=vendor_id]"), "vendor_id value"
      end
    end

    context "a valid submission" do 
      setup do       
        @options = options.merge(:vendor_id => "VID")

        visit app.url(:lookup)
        fill_in_auth
        select "Vendor ID", :from => "lookup_form[package_id]"
        fill_in "lookup_form[package_id_value]", :with => @options[:vendor_id]
        click_button "Lookup"
        
        @job = LookupJob.last
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

