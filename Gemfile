source "https://rubygems.org"

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'haml'
gem 'activerecord', :require => "active_record"

gem "daemons"
gem "delayed_job"
gem "delayed_job_active_record"

gem "tilt"
gem "coderay"
gem "will_paginate", "~> 3.0"
gem "itunes_store_transporter", "~> 0.1.3"
gem "padrino_bootstrap_forms", "~> 0.1.1", :require => "bootstrap_forms"

# Or Individual Gems
%w(core gen helpers).each do |g|
  gem "padrino-" + g, "0.12.6"
end

gem "sqlite3", :group => [:development, :test]

# Test requirements
group :test do
  gem "rspec"
  gem "shoulda-matchers", :require => false
  gem "rack-test", :require => "rack/test"
  gem "database_cleaner"
  gem "capybara-screenshot"
  gem "poltergeist"
  gem "phantomjs", :require => 'phantomjs/poltergeist'
end

group :test, :development do
  gem "factory_girl"
end
