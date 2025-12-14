FactoryBot.define do
  factory(:air_gradient_measures, class: "AirGradient::Measures") do
    skip_create
    initialize_with { AirGradient::Measures.new(**attributes) }

    co2 { 415 }
    humidity { 45.5 }
    nox { 12 }
    pm01 { 3 }
    pm02 { 7 }
    pm10 { 15 }
    temp { 72.5 }
    tvoc { 25 }
  end
end
