module AirGradient
  # Hoisted to a constant so Sorbet can resolve the superclass; it
  # rejects arbitrary expressions in an ancestor position (srb.help/4002).
  SensorData = Data.define(:name, :url)

  class Sensor < SensorData
    def current_measures = Measures.current(url:)
  end
end
