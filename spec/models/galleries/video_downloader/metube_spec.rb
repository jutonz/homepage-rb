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

  describe "#add" do
    it "enqueues a download via POST /add" do
      stub = FakeMetube.stub(method: :post, path: "/add")
        .with(body: {
          url: "https://example.com/v",
          download_type: "video",
          quality: "best",
          format: "mp4",
          custom_name_prefix: "rvd-1",
          auto_start: true
        })
        .to_return(
          body: {status: "ok"}.to_json,
          headers: {"content-type" => "application/json"},
          status: 200
        )

      result = described_class.new.add(
        url: "https://example.com/v",
        prefix: "rvd-1"
      )

      expect(stub).to have_been_requested
      expect(result).to eql({"status" => "ok"})
    end
  end

  describe "#delete" do
    it "removes an entry via POST /delete" do
      stub = FakeMetube.stub(method: :post, path: "/delete")
        .with(body: {ids: ["abc"], where: "done"})
        .to_return(
          body: {status: "ok"}.to_json,
          headers: {"content-type" => "application/json"},
          status: 200
        )

      result = described_class.new.delete("abc")

      expect(stub).to have_been_requested
      expect(result).to eql({"status" => "ok"})
    end
  end
end
