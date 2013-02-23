$: << File.expand_path(File.dirname(__FILE__) + "/lib")

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

require "test/unit"
require 'tmpdir'
require 'capybara/dsl'
require 'rack_test_flash'
require 'transporter_job_test_methods'

Capybara.app = Padrino.application

config = AppConfig.first_or_initialize
config.output_log_directory = Dir.tmpdir
config.save!

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
  include Rack::Test::Methods
  include Rack::Test::Flash
  include TransporterJobTestMethods

  def app
    ItunesStoreTransporterWeb
  end

  def options
    { :username  => "sshaw",
      :password  => "--><--",
      :shortname => "pequena" }
  end

  def self.should_redisplay_the_jobs_page
    should "redisplay the job's page" do
      assert !last_response.redirect?
    end
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
    config.update_attributes(optz)
    config
  end
end
