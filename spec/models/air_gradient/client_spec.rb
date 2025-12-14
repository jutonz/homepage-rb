require "rails_helper"

RSpec.describe AirGradient::Client do
  describe "#get" do
    it "makes a get request" do
      url = "http://192.168.1.2"
      stub = FakeAirGradient.stub(
        url:,
        method: :get,
        path: "/hello"
      ).to_return(
        body: "world",
        status: 200
      )

      response = described_class.new(url:).get("/hello")

      expect(stub).to have_been_requested
      expect(response.body).to eql("world")
    end

    it "parses response as json" do
      url = "http://192.168.1.2"
      stub = FakeAirGradient.stub(
        url:,
        method: :get,
        path: "/hello"
      ).to_return(
        body: {planet: "world"}.to_json,
        headers: {"content-type" => "application/json"},
        status: 200
      )

      response = described_class.new(url:).get("/hello")

      expect(stub).to have_been_requested
      expect(response.body).to eql({"planet" => "world"})
    end

    it "raises if request is unsuccessful" do
      url = "http://192.168.1.2"
      FakeAirGradient.stub(
        url:,
        method: :get,
        path: "/hello"
      ).to_return(
        body: "error",
        status: 500
      )

      expect {
        described_class.new(url:).get("/hello")
      }.to raise_error(Faraday::ServerError)
    end
  end
end
