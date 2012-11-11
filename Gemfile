source :rubygems

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'haml'
gem 'activerecord', :require => "active_record"
gem 'sqlite3'

gem "daemons"
gem "delayed_job", "~> 3.0.0"
gem "delayed_job_active_record"
gem "coderay"
gem "will_paginate", "~> 3.0"
gem "itunes_store_transporter", "~> 0.0.2"
gem "padrino_bootstrap_forms", :require => "bootstrap_forms"

# Or Individual Gems
%w(core gen helpers).each do |g|
  gem 'padrino-' + g, '0.10.7'
end

# Test requirements
group :test do 
  gem 'rr'
  gem 'shoulda', '~> 2.11.3'
  gem 'rack-test', :require => 'rack/test'
  gem 'capybara', '~> 1.1.2'
  gem 'capybara-webkit', '~> 0.12.1'
end
