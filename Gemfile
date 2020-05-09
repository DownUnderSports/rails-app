source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

gem "active_type", ">= 0.3.2"
gem "autoprefixer-rails", ">= 5.0.0.1"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", ">= 1.4.2", require: false
gem "coffee-rails"
gem "dotenv-rails", ">= 2.0.0"
gem "pg", ">= 0.18"
gem "pgcli-rails"
gem "puma", "~> 4.1"
gem "rack-canonical-host", github: "SampsonCrowley/rack-canonical-host"
gem "rails", "~> 6.0.2.2"
gem "redis", "~> 4.0"
gem "sass-rails", "~> 6.0"
gem "sidekiq", ">= 4.2.0"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 4.0"

group :production do
  gem "postmark-rails"
end

group :development, :test do
  gem "byebug"
end

group :development do
  gem "amazing_print"
  gem "annotate", ">= 2.5.0"
  gem "better_errors"
  gem "binding_of_caller"
  gem "brakeman", require: false
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "guard", ">= 2.2.2", require: false
  gem "guard-livereload", require: false
  gem "guard-minitest", require: false
  gem "letter_opener"
  gem "listen", ">= 3.0.5"
  gem "overcommit", ">= 0.37.0", require: false
  gem "rack-livereload"
  gem "rubocop", ">= 0.80.0", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "terminal-notifier", require: false
  gem "terminal-notifier-guard", require: false
end

group :test do
  gem "capybara", ">= 2.15"
  gem "launchy"
  gem "minitest-ci", ">= 3.3.0", require: false
  gem "mock_redis"
  gem "selenium-webdriver"
  gem "shoulda-context"
  gem "shoulda-matchers", ">= 3.0.1"
  gem "webdrivers"
end
