RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers/**/*.rb")].each(&method(:require))

require "shoulda/matchers"
require "capybara/dsl"
#require 'capybara/poltergeist'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods

  config.include Module.new {
    def stub_itms(job)
      transporter = double()
      allow(job).to receive(:itms) { transporter }
      transporter
    end
  }

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
end

FactoryGirl.find_definitions

Capybara.app = Padrino.application

# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app PadTestRspec::App
#   app PadTestRspec::App.tap { |a| }
#   app(PadTestRspec::App) do
#     set :foo, :bar
#   end
#
def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
