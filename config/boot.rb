# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

$LOAD_PATH.concat Dir[Padrino.root("vendor/**/lib")]
$LOAD_PATH << Padrino.root("lib")

require "will_paginate/active_record"
require "sinatra/config_file"
require "i18n/backend/fallbacks"

# Only used in production env
ITMSWEB_CONFIG = Padrino.root("config/itmsweb.yml")

##
# Enable devel logging
#
# Padrino::Logger::Config[:development][:log_level]  = :devel
# Padrino::Logger::Config[:development][:log_static] = true
#

##
# Add your before load hooks here
#
Padrino.before_load do
  # Padrino loads these after the boot process, which is too late
  I18n.load_path.concat Dir[Padrino.root("app/locale/*.yml")]
  I18n.config = I18n::Env::Config.new
  I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
end

##
# Add your after load hooks here
#
Padrino.after_load do
end

Padrino::Application.prerequisites.concat Dir[Padrino.root("app/forms/*.rb")]
Padrino.load!
