require_relative 'boot'
require_relative 'version'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DownUnderSports
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # db settings
    config.active_record.pluralize_table_names = false
    config.active_record.schema_format = :sql
    config.active_record.dump_schemas = :all
    config.active_record.cache_timestamp_format = :nsec

    # time settings
    config.time_zone = 'Mountain Time (US & Canada)'
    config.active_record.default_timezone = :utc

    # generator settings
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # config.session_store :disabled

    # config.middleware.delete "ActionDispatch::Session::CookieStore"
    config.middleware.delete "ActionDispatch::Flash"

    config.logidze.ignore_log_data_by_default = true

    overrides = "#{Rails.root}/lib/overrides"
    Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      Dir.glob("#{overrides}/**/*.rb").each do |file|
        load file
      end
    end
  end
end
