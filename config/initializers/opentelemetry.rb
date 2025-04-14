if Rails.application.config.x.enable_metrics
  require "opentelemetry/sdk"
  require "opentelemetry/instrumentation/all"
  require "opentelemetry-exporter-otlp"

  # ENV["OTEL_TRACES_EXPORTER"] = "console"
  ENV["OTEL_EXPORTER_OTLP_ENDPOINT"] = "http://otel-collector.monitoring.svc.cluster.local:4318"

  # https://opentelemetry.io/docs/languages/ruby/getting-started/
  OpenTelemetry::SDK.configure do |c|
    c.service_name = "homepage-rb"
    c.use_all # enables all instrumentation!
  end
end
