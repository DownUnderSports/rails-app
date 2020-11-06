Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # use lvh.me as main dev host
  config.hosts << /([^.]+\.)?lvh\.me/

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :development

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Automatically dump schema after running migrations
  config.active_record.dump_schema_after_migration = false if CoerceBoolean.from(ENV["RAILS_SKIP_SCHEMA_DUMP"])

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker


  # setup logging to both STDOUT and file

  # config.log_level = :debug
  # config.log_formatter = ActiveSupport::Logger::SimpleFormatter.new

  stdout_logger = ActiveSupport::Logger.new(STDOUT)
  stdout_logger.level = config.log_level
  stdout_logger.formatter = config.log_formatter
  stdout_logger = ActiveSupport::TaggedLogging.new(stdout_logger)

  main_logger = begin
    logger = ActiveSupport::Logger.new(config.default_log_file)
    logger.formatter = config.log_formatter
    logger.level = config.log_level
    logger = ActiveSupport::TaggedLogging.new(logger)
    logger
  rescue StandardError
    path = config.paths["log"].first
    logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDERR))
    logger.level = ActiveSupport::Logger::WARN
    logger.warn(
      "Rails Error: Unable to access log file. Please ensure that #{path} exists and is writable " \
      "(ie, make it writable for user and group: chmod 0664 #{path}). " \
      "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
    )
    logger
  end

  config.logger = stdout_logger

  stdout_logger.extend ActiveSupport::Logger.broadcast(main_logger)
end
