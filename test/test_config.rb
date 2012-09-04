$: << File.expand_path(File.dirname(__FILE__) + "/lib")

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

require 'tmpdir'
require 'shoulda/active_record' 
require 'capybara/dsl'
require 'form_actions'
require 'message_matchers'
require 'transporter_job_test_methods'

Capybara.app = Padrino.application

config = AppConfig.instance
config.output_log_directory = Dir.tmpdir
config.save!

class Test::Unit::TestCase
  include RR::Adapters::TestUnit 
  include Rack::Test::Methods
  include TransporterJobTestMethods  

  def app
    Padrino.application
  end
end

class CapybaraTestCase < Test::Unit::TestCase
  include Capybara::DSL
  include MessageMatchers
  include FormActions
  
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def self.should_create_the_job
    should "redirect to the job's page" do
      assert_equal "/jobs/#{TransporterJob.last.id}", current_path
    end
    
    should "display a 'job added' message" do
      assert job_added_message?
    end
  end
end
