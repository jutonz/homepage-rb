require "prometheus_exporter/client"

module Metrics
  class SolidQueueMetricsJob < ApplicationJob
    queue_as :priority

    def perform
      return unless Rails.application.config.x.enable_metrics

      client = PrometheusExporter::Client.default

      client.register(
        :gauge,
        :solid_queue_ready_execution_count,
        "number of jobs in queue"
      ).observe(SolidQueue::ReadyExecution.count)

      client.register(
        :gauge,
        :solid_queue_claimed_execution_count,
        "number of jobs currently processing"
      ).observe(SolidQueue::ClaimedExecution.count)
    end
  end
end
