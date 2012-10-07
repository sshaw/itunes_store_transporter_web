require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
require "options"

class ConfigControllerTest < CapybaraTestCase
  context "configuring the transporter" do
    setup { visit app.url(:config) }

    [:username, :password, :shortname].each do |opt|
      context "the #{opt}" do 
        should "not be required" do          
          click_button "Save"
          assert has_no_content?("#{opt.capitalize} required")
        end
      end
    end

    context "the rate" do
      should "be a number" do
        fill_in "Rate", :with => "A"
        click_button "Save"
        assert rate_not_number?
      end
      
      should "be greater than 0" do
        fill_in "Rate", :with => 0
        click_button "Save"
        assert rate_gt_zero?
      end
    end

    context "the transport field" do
      should "contain all the options" do 
        assert has_select?("Transport", :options => ["Transporter's Default"] + Options::TRANSPORTS)
      end
    end

    context "a valid submission" do 
      setup do       
        @options = options.merge(:rate => 100, :transport => "Aspera", :path => "MyTransporter")
        visit app.url(:config)
        fill_in_auth
        select @options[:transport], :from => "Transport"
        fill_in "Rate", :with => @options[:rate]
        # We should make sure this is a file...
        find("#selected_path").set(@options[:path])    
        click_button "Save"
        @config = AppConfig.first_or_initialize
      end
            
      should "display a saved message" do 
        assert has_content?("Configuration saved")
      end

      [:username, :password, :shortname, :rate, :transport, :path].each do |opt|
        should "set the #{opt} option" do    
          assert_equal @options[opt], @config[opt]
        end
      end
    end    
  end
end

