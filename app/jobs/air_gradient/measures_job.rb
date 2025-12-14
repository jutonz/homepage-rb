require "prometheus_exporter/client"

module AirGradient
  class MeasuresJob < ApplicationJob
    SENSORS = Rails.application.credentials.air_gradient_sensors.map do |sensor|
      Sensor.new(name: sensor[:name], serial_no: sensor[:serial_no])
    end

    def perform
      return unless Rails.application.config.x.enable_metrics
      SENSORS.each do |sensor|
        fetch_and_upload_metrics(sensor:)
      end
    end

    private

    def fetch_and_upload_metrics(sensor:)
      measures = Measures.current(serial_no: sensor.serial_no)

      client = PrometheusExporter::Client.default
      client
        .register(:gauge, :co2, "CO2")
        .observe(measures.co2, sensor: sensor.name)
      client
        .register(:gauge, :humidity, "humidity")
        .observe(measures.humidity, sensor: sensor.name)
      client
        .register(:gauge, :pm01, "PM1.0")
        .observe(measures.pm01, sensor: sensor.name)
      client
        .register(:gauge, :pm02, "PM2.5")
        .observe(measures.pm02, sensor: sensor.name)
      client
        .register(:gauge, :pm10, "PM10")
        .observe(measures.pm10, sensor: sensor.name)
      client
        .register(:gauge, :temp, "temperature")
        .observe(measures.temp, sensor: sensor.name)
      client
        .register(:gauge, :tvoc, "tvoc")
        .observe(measures.tvoc, sensor: sensor.name)
    end
  end
end
