source "https://rubygems.org"

gem "rake"
gem "sinatra-contrib"
gem "haml", "5.0.0"
gem "activerecord", "~> 4.2"
gem "daemons"
gem "delayed_job"
gem "delayed_job_active_record"
gem "tilt"
gem "coderay"
gem "will_paginate", "~> 3.0"
gem "itunes_store_transporter", "0.2.1"
gem "padrino_bootstrap_forms", "~> 0.1.2", :require => "bootstrap_forms"
gem "page_number", "~> 0.1.0"
gem "i18n-env-config"
gem "mail"
gem "valid_email"

%w(core gen helpers mailer).each do |g|
  gem "padrino-" + g, "0.12.6"
end

group :test do
  # Check needed for install (ruby install.rb) on 1.9.3
  # But for 1.9.3 testing see gemfiles directory
  gem "shoulda-matchers", RUBY_VERSION == "1.9.3" ? "2.8.0" : "~> 3.1.1"
  gem "rack-test", "0.6.3", :require => "rack/test"
  gem "database_cleaner"
  gem "capybara-screenshot"
  gem "poltergeist"
  # No Windows support, see: https://github.com/colszowka/phantomjs-gem/pull/77
  gem "phantomjs", :require => "phantomjs/poltergeist", :install_if => !Gem.win_platform?
end

group :test, :development do
  gem "factory_girl"
  gem "rspec"
  gem "sqlite3", "~> 1.3.0"
end

gem "kramdown", :group => :development
