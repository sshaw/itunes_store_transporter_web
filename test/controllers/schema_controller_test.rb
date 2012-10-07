require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class SchemaControllerTest < CapybaraTestCase
  context "looking up a schema" do
    setup { visit app.url(:schema) }

    context "version number" do
      should "be required" do
        click_button "Retrieve Schema"
        assert has_content?("Version number can't be blank")
      end

      should "be a number" do
        fill_in "Version number", :with => "A"
        click_button "Retrieve Schema"
        assert has_content?("Version number is not a number")
      end
    end

    context "version name" do
      should "have the right version options" do
        assert has_select?("Version name", :options => ["film", "tv"])
      end
    end

    context "schema type" do
      should "have the right type options" do
        assert has_select?("Type", :options => ["transitional", "strict"])
      end
    end

    context "a valid submission" do
      setup do
        # apple_id too
        @options = options.merge(:type => "strict")
        visit app.url(:schema)
        fill_in_auth
        select "film", :form => "Version name"
        select @options[:type], :from => "Type"
        fill_in "Version number", :with => 11.5
        click_button "Retrieve Schema"

        @job = SchemaJob.last
      end

      should_create_the_job
      
      should "set the version option" do
        assert_equal "film11.5", @job.options[:version]
      end

      [:username, :password, :shortname, :type].each do |opt|
        should "set the #{opt} option" do
          assert_equal @options[opt], @job.options[opt]
        end
      end
    end
  end
end
