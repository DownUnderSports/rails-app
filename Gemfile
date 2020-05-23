source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# core gems
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
gem "pg", "~> 1.1", '>= 1.1.2'
gem 'puma', '~> 4.3'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'redis', '~> 4.0'
gem 'coerce_boolean', '~> 0.1'

# extension gems
gem 'aasm', '~> 5.0', '>= 5.0.1'
gem 'store_as_int', '~> 0.0', '>= 0.0.19'
gem 'csv_rb', '~> 6.0.2', '>= 6.0.2.3'

# file storage gems
gem "aws-sdk-s3", '>= 1.30.1', require: false


# security handling gems
gem "rbnacl", "~> 7.1"
gem 'secure_web_token', '~> 0.1'
gem "openssl", "~> 2.1"
gem "pundit", "~> 2.1"

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'braintree', '~> 2.90', '>= 2.90.0'
gem 'browser', '~> 2.5', '>= 2.5.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
