$: << File.expand_path(File.dirname(__FILE__) + "/support")

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'rack_test_flash'
require 'transporter_job_test_methods'
require 'job_form_test_methods'


Capybara.app = Padrino.application

config = AppConfig.first_or_initialize
config.output_log_directory = Dir.tmpdir
config.save!

class Minitest::Test
  include Shoulda::Matchers::ActiveModel
  extend Shoulda::Matchers::ActiveModel

  include Shoulda::Matchers::ActiveRecord
  extend Shoulda::Matchers::ActiveRecord

  extend JobFormTestMethods

  include RR::Adapters::TestUnit
  include TransporterJobTestMethods
end

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Rack::Test::Methods
  include Rack::Test::Flash

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    TransporterJob.delete_all
  end

  def set_defaults(optz = options)
    config = AppConfig.first_or_initialize
    config.update_attributes!(optz)
    config
  end

  def self.app
    ItunesStoreTransporterWeb
  end

  def app
    self.class.app
  end

  def options
    { :username  => "sshaw",
      :password  => "--><--",
      :shortname => "pequena" }
  end

  def self.should_return_success
    should "return success" do
      assert last_response.ok?
    end
  end

  def self.should_create_the_job
    should_return_success

    should "redirect to the new job's page" do
      assert_equal app.url(:job, TransporterJob.last.id), last_request.path
    end

    should "display a job added message" do
      assert_match /job added/i, flash[:success]
    end
  end

  def self.should_have_a_search_dialog(url)
    context "when the search link is clicked" do
      setup do
        Capybara.current_driver = :poltergeist
        visit url
        click_link "Search"
      end

      should "display the search form" do
        assert find("#search").visible?
      end

      context "when the clear link is clicked" do
        setup do
          select "Queued", :from => "state"
          select "Lookup", :from => "type"
          select "Normal", :from => "priority"
          fill_in "target", :with => "12345"
          fill_in "_updated_at_from", :with => "1/1/71"
          fill_in "_updated_at_to", :with => "1/1/72"
          click_link "Clear"
        end

        should "clear all the form fields" do
          within("#search") do
            all("select,input[type=text]").each { |e| assert e.value.empty?, "field '#{e[:name]}' not cleared" }
          end
        end
      end

      context "when the start date field receives the focus" do
        setup { find_field("_updated_at_from").trigger("focus") }

        should "display the calendar" do
          assert find(".ui-datepicker").visible?
        end
      end

      context "when the Search button is clicked" do
        setup do
          fill_in "target", :with => "12345"
          click_button "Search"
        end

        should "submit the form" do
          assert_equal app.url(:search), current_path
        end


      end
    end
  end

  def self.should_toggle_auth_fields(url)
    context "username and password fields" do
      setup { Capybara.current_driver = :poltergeist }

      context "without defaults" do
        setup do
          set_defaults(:username => nil, :password => nil)
          visit url
        end

        should "be visible" do
          assert find('input[name$="username]"]').visible?
          assert find('input[name$="password]"]').visible?
          assert find('input[name$="shortname]"]').visible?
        end
      end

      context "with defaults" do
        setup do
          set_defaults
          visit url
        end

        should "not be visible" do
          assert !find('input[name$="username]"]').visible?
          assert !find('input[name$="password]"]').visible?
          assert !find('input[name$="shortname]"]').visible?
        end

        context "when the 'Edit...' link is clicked" do
          setup { click_link("Edit usernames and password") }

          should "be visible" do
            assert find('input[name$="username]"]').visible?
            assert find('input[name$="password]"]').visible?
            assert find('input[name$="shortname]"]').visible?
          end
        end
      end
    end
  end
end
