FactoryBot.define do
  factory(:air_gradient_sensor, class: "AirGradient::Sensor") do
    skip_create
    initialize_with { AirGradient::Sensor.new(**attributes) }

    url { "https://192.168.2.1" }
    name { "Office" }
  end
end
