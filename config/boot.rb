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
  if ENV["LANG"] && !ENV["LANG"].empty?
    # Our localizations don't (yet) support a country part
    lang = ENV["LANG"].split(".").first.split("_").first.to_sym
    I18n.default_locale = lang if I18n.available_locales.include?(lang)
  end
end

##
# Add your after load hooks here
#
Padrino.after_load do
end

Padrino::Application.prerequisites.concat Dir[Padrino.root("app/forms/*.rb")]
Padrino.load!
