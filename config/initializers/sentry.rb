# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry_dsn
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # sentry-rails 7.0.0 enables Rails structured logging by default, which
  # ships every ActiveRecord query and controller action to Sentry Logs.
  config.rails.structured_logging.enabled = false

  config.traces_sample_rate = 0.1
  config.profiles_sample_rate = 0.1
end
