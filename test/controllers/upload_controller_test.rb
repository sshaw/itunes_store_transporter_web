require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class UploadControllerTest < CapybaraTestCase
  should_toggle_auth_fields(app.url(:upload))

  context "uploading a package" do
    setup do
      Capybara.current_driver = :webkit
      visit app.url(:upload)
    end

    context "the package field" do
      should "have a file dialog" do
        click_on "Select Package"
        assert find("div.modal", :visible => true).has_content?("Select Your Package")
      end

      should "be required" do
        click_upload
        assert package_blank?
      end

      should "end in .itmsp" do
        # type=hidden
        fill_in_package("some_thang")
        click_upload
        assert package_name_invalid?
      end
    end

  #   context "the rate" do
  #     should "be a number" do
  #       fill_in "Rate", :with => "A"
  #       click_upload
  #       assert rate_not_number?
  #     end

  #     should "be greater than 0" do
  #       fill_in "Rate", :with => 0
  #       click_upload
  #       assert rate_gt_zero?
  #     end
  #   end

  #   context "the transport field" do
  #     should "contain the default" do
  #       assert has_selector?("select option[value='']")
  #     end

  #     should "contain Aspera" do
  #       assert has_selector?("select option[value=Aspera]")
  #     end

  #     should "contain DAV" do
  #       assert has_selector?("select option[value=DAV]")
  #     end

  #     should "contain Signiant" do
  #       assert has_selector?("select option[value=Signiant]")
  #     end
  #   end

  #   [:username, :password].each do |opt|
  #     context "the #{opt}" do
  #       should "be required" do
  #         click_button "Upload"
  #         assert has_content?("#{opt.capitalize} can't be blank")
  #       end
  #     end
  #   end

  #   context "with default settings" do
  #     setup do
  #       @config = set_defaults(options.merge(:rate => 100, :transport => "Signiant"))
  #       visit app.url(:upload)
  #     end

  #     [:rate, :transport, :username, :password, :shortname].each do |opt|
  #       should "set the #{opt} field to the default" do
  #         assert_equal @config[opt].to_s, find_field("upload_form[#{opt}]").value
  #       end
  #     end
  #   end

    context "username and password fields" do
      context "without defaults" do
        should "be visible" do
          assert find_field("upload_form[username]").visible?
          assert find_field("upload_form[password]").visible?
          assert find_field("upload_form[shortname]").visible?
        end
      end

      context "with defaults" do
        setup { set_defaults; p "set_def!" }

        should "not be visible" do
          assert !find_field("upload_form[username]").visible?
          assert !find_field("upload_form[password]").visible?
          assert !find_field("upload_form[shortname]").visible?          
        end        

        context "when the 'Edit...' link is clicked" do 
          setup {  p "clikc!"; click_link("Edit usernames and password") } 

          should "be visible" do
            assert find_field("upload_form[username]").visible?
            assert find_field("upload_form[password]").visible?
            assert find_field("upload_form[shortname]").visible?
          end
        end       
      end
    end    
  end

  # context "with all the required fields" do
  #   setup do
  #     # should check if file ex on sever
  #     @options = options.merge(:rate      => 1,
  #                              :delete    => true,
  #                              :transport => "Aspera",
  #                              :success   => "successdir",
  #                              :failure   => "failuredir",
  #                              :package   => "package.itmsp")

  #     visit app.url(:upload)
  #     [:success, :failure].each do |opt|
  #       find_by_id("selected_#{opt}").set(@options[opt])
  #     end

  #     fill_in_auth
  #     fill_in_package @options[:package]
  #     fill_in "Rate", :with => @options[:rate]
  #     check "Delete on success"
  #     select @options[:transport], :from => "Transport"
  #     click_upload

  #     @job = UploadJob.last
  #   end

  #   should_create_the_job

  #   [:rate, :delete, :username, :password, :shortname, :transport, :package, :success, :failure].each do |opt|
  #     should "set the job's #{opt} option" do
  #       assert_equal @options[opt], @job.options[opt]
  #     end
  #   end
  # end
  
  protected
  def click_upload
    click_button "Upload"
  end
end
