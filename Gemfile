source "https://rubygems.org"

gem "rake"
gem "sinatra-contrib"
gem "haml"
gem "activerecord", "~> 4.2.0", :require => "active_record"
gem "daemons"
gem "delayed_job"
gem "delayed_job_active_record"
gem "tilt"
gem "coderay"
gem "will_paginate", "~> 3.0"
gem "itunes_store_transporter", :github => "sshaw/itunes_store_transporter", :branch => "master"
gem "padrino_bootstrap_forms", "~> 0.1.2", :require => "bootstrap_forms"
gem "page_number", :gist => "83f7ad7ce9c8f92a833f6d6530a2495c"
gem "i18n-env-config"
gem "mail"
gem "valid_email"

%w(core gen helpers mailer).each do |g|
  gem "padrino-" + g, "0.12.6"
end

group :test do
  gem "shoulda-matchers", "~> 3.1.1"
  gem "rack-test", :require => "rack/test"
  gem "database_cleaner"
  gem "capybara-screenshot"
  gem "poltergeist"
  # No Windows support, see: https://github.com/colszowka/phantomjs-gem/pull/77
  gem "phantomjs", :require => "phantomjs/poltergeist", :install_if => !Gem.win_platform?
end

group :test, :development do
  gem "factory_girl"
  gem "rspec"
  gem "sqlite3"
end

gem "kramdown", :group => :development
