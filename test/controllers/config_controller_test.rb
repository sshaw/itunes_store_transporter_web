require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class ConfigControllerTest < CapybaraTestCase
  context "when the Select Path link is clicked" do
    setup do
      Capybara.current_driver = :webkit
      visit app.url(:config)
      click_link "Select Path"
    end

    should "display the transporter location dialog" do
      assert find(".modal").visible?
    end

    context "when the Close button is clicked" do
      setup { click_link "Close" }

      should "close the dialog" do
        assert !find(".modal").visible?
      end
    end

    context "when the X link is clicked" do
      setup { click_link "&times" }

      should "close the dialog" do
        assert !find(".modal").visible?
      end
    end

    context "browsing a directory in the dialog" do
      setup do
        @element = first("div.listing li.directory a")
        2.times { @element.click }
        #mock(FsUtil).ls(@dir, is_a(Hash))
        #mock(FsUtil).ls
      end

      # should "fetch the listing" do
      #   assert_received(FsUtil) { |fs| fs.ls } #(@dir, is_a(Hash)) }
      # end

      should "display the directory's listing" do
        # should setup a test dir structure
        assert has_selector?(:xpath, "#{@element.path}/following-sibling::ul")
      end
      
      # should "cache the fetched listing" do
      # end
    end
    
    context "choosing a directory in the dialog" do
      setup do
        @element = first("div.listing li.directory a")
        @element.click
        click_link "Select"
      end
      
      should "display the selected directory" do
        # check text of #path for rel
        #assert has_selector?("#path[data-content='#{@element[:rel]}']")
        assert_equal @element[:rel], find("#selected_path").value
      end     
    end
  end
  
  context "POST to status" do
    context "with valid parameters" do
      setup do
        @options = options.merge(:rate => 100, :transport => "Aspera", :path => "MyTransporter")
        post app.url(:config), :app_config => @options
        follow_redirect!
        @config = AppConfig.first_or_initialize
      end

      should "redirect back to the config page" do
        assert_equal app.url(:config), last_request.path
      end

      should "display a configuration saved message" do
        assert_equal flash[:success], "Configuration saved."
      end

      should "save the configuration" do
        @options.each { |k,v| assert_equal v, @config[k.to_s], "option #{k}" }
      end
    end

    context "without valid parameters" do
      setup { post app.url(:config) }

      should "redisplay the config page" do
        assert_equal app.url(:config), last_request.path
      end
    end
  end

  context "GET to config" do
    setup { get app.url(:config) }

    should "return success" do
      assert last_response.ok?
    end
  end
end
