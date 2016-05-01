RACK_ENV = "test" unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers/**/*.rb")].each(&method(:require))

$: << File.dirname(__FILE__) + "/support"

require "tmpdir"

require "shoulda/matchers"
require "capybara/dsl"
require "capybara/poltergeist"
require "capybara/rspec"
require "capybara-screenshot/rspec"

require "features/actions"
require "features/matchers"
require "helpers"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods

  config.include FeatureMatchers
  config.include FeatureActions
  config.include Helpers

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.around :each do |ex|
    DatabaseCleaner.strategy = :truncation if ex.metadata[:js]
    DatabaseCleaner.cleaning { ex.run }
    DatabaseCleaner.strategy = :transaction
  end
end

FactoryGirl.find_definitions

Capybara.save_and_open_page_path = "tmp/capybara"
Capybara.javascript_driver = :poltergeist
Capybara.app = ItunesStoreTransporterWeb
Capybara::Screenshot.prune_strategy = :keep_last_run

# This is necessary because of https://github.com/sshaw/padrino_bootstrap_forms/issues/10
class Test::Unit::AutoRunner
  def self.need_auto_run?
    false
  end
end

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
  @app ||= ItunesStoreTransporterWeb
end