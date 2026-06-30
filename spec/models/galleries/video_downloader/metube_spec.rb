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

    it "parses JSON bodies served as text/plain" do
      body = {"done" => [], "queue" => [], "pending" => []}
      FakeMetube.stub(method: :get, path: "/history")
        .to_return(
          body: body.to_json,
          headers: {"content-type" => "text/plain; charset=utf-8"},
          status: 200
        )

      result = described_class.new.history

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

    it "raises when MeTube rejects the add with an error status" do
      FakeMetube.stub(method: :post, path: "/add")
        .to_return(
          body: {status: "error", msg: "could not download"}.to_json,
          headers: {"content-type" => "application/json"},
          status: 200
        )

      expect {
        described_class.new.add(url: "https://example.com/v", prefix: "rvd-1")
      }.to raise_error(described_class::Error, "could not download")
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

  describe "#delete_by_prefix" do
    it "deletes matching queue and done entries" do
      history = {
        "queue" => [
          {"custom_name_prefix" => "rvd-1", "url" => "u-q"},
          {"custom_name_prefix" => "rvd-2", "url" => "u-x"}
        ],
        "done" => [
          {"custom_name_prefix" => "rvd-1", "url" => "u-d"}
        ]
      }
      FakeMetube.stub(method: :get, path: "/history").to_return(
        body: history.to_json,
        headers: {"content-type" => "application/json"},
        status: 200
      )
      queue_delete = FakeMetube.stub(method: :post, path: "/delete")
        .with(body: {ids: ["u-q"], where: "queue"})
        .to_return(
          body: "{}",
          headers: {"content-type" => "application/json"},
          status: 200
        )
      done_delete = FakeMetube.stub(method: :post, path: "/delete")
        .with(body: {ids: ["u-d"], where: "done"})
        .to_return(
          body: "{}",
          headers: {"content-type" => "application/json"},
          status: 200
        )

      described_class.new.delete_by_prefix("rvd-1")

      expect(queue_delete).to have_been_requested
      expect(done_delete).to have_been_requested
    end
  end

  describe "#fetch_file" do
    it "returns the raw bytes for the requested file" do
      bytes = "\x00\x01video".b
      stub = FakeMetube.stub(
        method: :get,
        path: "/download/rvd-1%20clip.mp4"
      ).to_return(
        body: bytes,
        headers: {"content-type" => "video/mp4"},
        status: 200
      )

      result = described_class.new.fetch_file("rvd-1 clip.mp4")

      expect(stub).to have_been_requested
      expect(result).to eql(bytes)
    end
  end
end
