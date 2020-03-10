Dir.glob("#{File.expand_path(__dir__)}/core_ext/*.rb").each do |d|
  require d
end

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
    Dir["#{config.root}/lib/groundwork/*"].map {|f| require_dependency f }

    ENV['GNUPGHOME'] = config.root.join('.gnupg').to_s

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.active_record.schema_format = :sql
    config.active_record.cache_timestamp_format = :nsec

    # Require library modules
    config.after_initialize do
      Dir["#{config.root}/lib/modules/**/*"].map {|f| require_dependency f }
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.time_zone = 'Mountain Time (US & Canada)'
    config.active_record.default_timezone = :utc

    # config.active_job.queue_adapter = :sidekiq
    # config.generators do |g|
    #   g.assets false
    # end

    config.action_mailer.smtp_settings = {
      :address        => Rails.application.credentials.dig(:mailer, :mailgun, :hostname),
      :port           => Rails.application.credentials.dig(:mailer, :mailgun, :port).to_s,
      :authentication => :plain,
      :user_name      => Rails.application.credentials.dig(:mailer, :mailgun, :username),
      :password       => Rails.application.credentials.dig(:mailer, :mailgun, :password),
      :domain         => 'downundersports.com',
      :enable_starttls_auto => true
    }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
    config.action_mailer.default_url_options = {
      host: "https://www.downundersports.com"
    }

    config.action_mailer.asset_host = "https://www.downundersports.com"

    Dir["#{config.root}/config/middlewares/*"].map {|f| require_dependency f }

    # Raven.configure do |config|
    #   config.dsn = 'https://f67cbaba7f024d64baff2f19d0251068:6c1f90ca440c4d9bb9ce4b7902f2372f@sentry.io/1774865'
    #   config.async = lambda { |event|
    #     SentryJob.perform_later(event)
    #   }
    #   config.environments = %w[ production development ]
    #   config.release = DownUnderSports::VERSION
    # end

    config.middleware.use QueueTimeLogger
  end
end
