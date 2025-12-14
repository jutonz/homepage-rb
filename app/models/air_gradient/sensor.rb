module AirGradient
  class Sensor < Data.define(:name, :url)
    def current_measures = Measures.current(url:)
  end
end
