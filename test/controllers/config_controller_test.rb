require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class ConfigControllerTest < CapybaraTestCase
  should_toggle_auth_fields(app.url(:config))

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
      setup { find(".modal a.close").click }

      should "close the dialog" do
	assert !find(".modal").visible?
      end
    end

    context "viewing a directory in the dialog" do
      setup do
	@element = find(dialog_dir_css)
	2.times { @element.click }
	#STDERR.puts "relrelrelrelrel: #{@element[:rel]}"
	#mock(FsUtil).ls(@element[:rel], is_a(Hash)) { ["/Applications/Ass"] }
	#sleep 2
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

    context "selecting a directory in the dialog" do
      setup do
	@element = first(dialog_dir_css)
	@element.click
	# Give the file browser time to recognize this as a single click
	sleep 1
	click_link "Select"
      end

      should "close the dialog" do
	assert !find(".modal").visible?
      end

      should "display the directory's name" do
	# check text of #path for rel
	# flunk 'Expected modal to be visible.'
	#assert_equal @element.text, find().value
	assert has_selector?("#path", :text => @element.text)
      end

      should "set the form field to the directoy's path" do
	assert_equal @element[:rel], find("#selected_path").value
      end

      # context "when mousing over the selected directory's name" do
      #   setup { find("#package").trigger(:mouseover) }

      #   should "display the directory's path" do
      #     assert has_selector?(".popover", :text => @element[:rel], :visible => true)
      #   end
      # end
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
      setup { post app.url(:config), :app_config => { :rate => "A" } }
      should_return_success
    end
  end

  context "GET to config" do
    setup { get app.url(:config) }
    should_return_success
  end

  def dialog_dir_css
    "div.listing li.directory a"
  end
end
