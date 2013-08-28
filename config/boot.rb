# Defines our constants
PADRINO_ENV  = ENV['PADRINO_ENV'] ||= ENV['RACK_ENV'] ||= 'development'  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

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
  require "sinatra/config_file"
end

##
# Add your after load hooks here
#
Padrino.after_load do
  require "will_paginate/active_record"
  Padrino.require_dependencies(Padrino.root("app/forms/*.rb"))
end

Padrino.load_paths.concat Dir[Padrino.root("vendor/**/lib")]
Padrino.load!
