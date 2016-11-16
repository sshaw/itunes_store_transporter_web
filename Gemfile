source "https://rubygems.org"

gem "rake"
gem "sinatra-flash", :require => "sinatra/flash"
gem "sinatra-contrib"
gem "haml"
gem "activerecord", :require => "active_record"
gem "daemons"
gem "delayed_job"
gem "delayed_job_active_record"
gem "tilt"
gem "coderay"
gem "will_paginate", "~> 3.0"
gem "itunes_store_transporter", "~> 0.1.3"
gem "padrino_bootstrap_forms", "~> 0.1.2", :require => "bootstrap_forms"
gem "page_number", :gist => "83f7ad7ce9c8f92a833f6d6530a2495c"
gem "i18n-env-config"
gem "rufus-scheduler"

%w(core gen helpers).each do |g|
  gem "padrino-" + g, "0.12.6"
end

group :test do
  gem "shoulda-matchers", "~> 3.1.1"
  gem "rack-test", :require => "rack/test"
  gem "database_cleaner"
  gem "capybara-screenshot"
  gem "poltergeist"
  gem "phantomjs", :require => 'phantomjs/poltergeist'
end

group :test, :development do
  gem "factory_girl"
  gem "rspec"
  gem "sqlite3"
end
