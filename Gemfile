source "https://rubygems.org"
ruby "1.9.2"

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'haml'
gem 'activerecord', :require => "active_record"

gem "daemons"
gem "delayed_job", "~> 3.0.0"
gem "delayed_job_active_record"

gem "tilt", "1.3.7"
gem "coderay"
gem "will_paginate", "~> 3.0"
gem "itunes_store_transporter", :git => "git://github.com/sshaw/itunes_store_transporter.git"
gem "padrino_bootstrap_forms", :require => "bootstrap_forms", :path => "../bootstrap_forms"
#gem "padrino_bootstrap_forms", :require => "bootstrap_forms", :git => "https://github.com/k2052/padrino_bootstrap_forms"
# Or Individual Gems
%w(core gen helpers).each do |g|
  gem 'padrino-' + g, '0.10.7'
end

gem 'slim', :group => [:development, :test]
gem 'sqlite3', :group => [:development, :test]

# Test requirements
group :test do 
  gem 'rr'
  gem 'shoulda', '~> 3'
  gem 'rack-test', :require => 'rack/test'
  gem 'capybara', '~> 1.1.2'
  gem 'capybara-webkit', '~> 0.13.0'
end
