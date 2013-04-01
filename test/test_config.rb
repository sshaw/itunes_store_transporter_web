$: << File.expand_path(File.dirname(__FILE__) + "/support")

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

require "test/unit"
require 'tmpdir'
require 'fileutils'
require 'capybara/dsl'
require 'rack_test_flash'
require 'transporter_job_test_methods'
require 'job_form_test_methods'

Capybara.app = Padrino.application

config = AppConfig.first_or_initialize
config.output_log_directory = Dir.tmpdir
config.save!

class Test::Unit::TestCase  
  extend JobFormTestMethods

  include RR::Adapters::TestUnit
  include Rack::Test::Methods
  include Rack::Test::Flash
  include TransporterJobTestMethods

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
      assert_match flash[:success], /job added/i
    end
  end
end

class CapybaraTestCase < Test::Unit::TestCase
  include Capybara::DSL
  
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

  def self.should_toggle_auth_fields(url)
    context "username and password fields" do
      setup { Capybara.current_driver = :webkit }

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
