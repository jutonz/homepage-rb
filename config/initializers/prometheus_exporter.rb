if Rails.application.config.x.enable_metrics
  require "prometheus_exporter"
  require "prometheus_exporter/middleware"

  # This reports stats per request like HTTP status and timings
  Rails.application.middleware.unshift(
    PrometheusExporter::Middleware,
    instrument: :prepend
  )
end
