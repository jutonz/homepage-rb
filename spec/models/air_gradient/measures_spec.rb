require "rails_helper"

RSpec.describe AirGradient::Measures do
  describe ".current" do
    it "fetches current measures" do
      response = {
        atmpCompensated: -40.0, # c and f are equal here
        noxIndex: 1,
        pm01: 0,
        pm02: 1.5,
        pm02Compensated: 1.31,
        pm10: 1.5,
        rco2: 1053,
        rhumCompensated: 60.59,
        tvocIndex: 153
      }
      serial_no = "abc123"
      stub = FakeAirGradient.stub(
        serial_no:,
        method: :get,
        path: "/measures/current"
      ).to_return(
        body: response.to_json,
        headers: {"content-type" => "application/json"},
        status: 200
      )

      measures = described_class.current(serial_no:)

      expect(stub).to have_been_requested
      expect(measures).to eql(described_class.new(
        co2: response[:rco2],
        humidity: response[:rhumCompensated],
        nox: response[:noxIndex],
        pm01: response[:pm01],
        pm02: response[:pm02Compensated],
        pm10: response[:pm10],
        temp: response[:atmpCompensated],
        tvoc: response[:tvocIndex]
      ))
    end
  end
end
