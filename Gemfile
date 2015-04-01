source "https://rubygems.org"

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'haml'
gem 'activerecord', :require => "active_record"

gem "daemons"
gem "delayed_job", "~> 3.0.0"
gem "delayed_job_active_record"

gem "tilt", "~> 1.3.6"
gem "coderay"
gem "will_paginate", "~> 3.0"
gem "itunes_store_transporter", "~> 0.1.3"
gem "padrino_bootstrap_forms", "0.0.2", :require => "bootstrap_forms"

# Or Individual Gems
%w(core gen helpers).each do |g|
  gem 'padrino-' + g, '0.10.7'
end

gem 'sqlite3', :group => [:development, :test]

# Test requirements
group :test do
  gem 'rr'
  gem 'minitest', :require => 'minitest/autorun'
  gem 'shoulda', '~> 3.5'
  gem 'rack-test', :require => 'rack/test'
  gem 'capybara', '~> 1.1.2'
  gem "poltergeist"
  gem "phantomjs", :require => 'phantomjs/poltergeist'
end
