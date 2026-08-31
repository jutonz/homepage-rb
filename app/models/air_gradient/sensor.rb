module AirGradient
  SensorData = Data.define(:name, :url)

  class Sensor < SensorData
    def current_measures = Measures.current(url:)
  end
end
