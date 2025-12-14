require "rails_helper"

RSpec.describe AirGradient::Client do
  describe "#get" do
    it "makes a get request" do
      serial_no = "abc123"
      stub = FakeAirGradient.stub(
        serial_no:,
        method: :get,
        path: "/hello"
      ).to_return(
        body: "world",
        status: 200
      )

      response = described_class.new(serial_no:).get("/hello")

      expect(stub).to have_been_requested
      expect(response.body).to eql("world")
    end

    it "parses response as json" do
      serial_no = "abc123"
      stub = FakeAirGradient.stub(
        serial_no:,
        method: :get,
        path: "/hello"
      ).to_return(
        body: {planet: "world"}.to_json,
        headers: {"content-type" => "application/json"},
        status: 200
      )

      response = described_class.new(serial_no:).get("/hello")

      expect(stub).to have_been_requested
      expect(response.body).to eql({"planet" => "world"})
    end

    it "raises if request is unsuccessful" do
      serial_no = "abc123"
      FakeAirGradient.stub(
        serial_no:,
        method: :get,
        path: "/hello"
      ).to_return(
        body: "error",
        status: 500
      )

      expect {
        described_class.new(serial_no:).get("/hello")
      }.to raise_error(Faraday::ServerError)
    end
  end
end
