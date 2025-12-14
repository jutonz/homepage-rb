require "rails_helper"

RSpec.describe AirGradient::Sensor do
  describe "#current_measures" do
    it "fetches current measures from the sensor's api" do
      sensor = build(:air_gradient_sensor)
      measures = build(:air_gradient_measures)
      allow(AirGradient::Measures).to receive(:current).and_return(measures)

      result = sensor.current_measures

      expect(result).to eql(measures)
      expect(AirGradient::Measures)
        .to have_received(:current)
        .with(url: sensor.url)
    end
  end
end
