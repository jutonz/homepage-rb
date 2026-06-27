require "rails_helper"

RSpec.describe Galleries::VideoDownloader::Metube do
  describe "#history" do
    it "returns the parsed history payload" do
      body = {"done" => [], "queue" => [], "pending" => []}
      stub = FakeMetube.stub(method: :get, path: "/history")
        .to_return(
          body: body.to_json,
          headers: {"content-type" => "application/json"},
          status: 200
        )

      result = described_class.new.history

      expect(stub).to have_been_requested
      expect(result).to eql(body)
    end

    it "raises when MeTube returns an error" do
      FakeMetube.stub(method: :get, path: "/history")
        .to_return(status: 500)

      expect { described_class.new.history }
        .to raise_error(Faraday::ServerError)
    end
  end
end
