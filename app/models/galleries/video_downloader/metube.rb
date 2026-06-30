module Galleries
  module VideoDownloader
    class Metube
      # Raised when MeTube replies HTTP 200 but rejects the request in the
      # body, e.g. {"status" => "error", "msg" => "..."}.
      Error = Class.new(StandardError)

      DOWNLOAD_TIMEOUT = 600

      def add(url:, prefix:)
        body = json.post("/add", {
          url:,
          download_type: "video",
          quality: "best",
          format: "mp4",
          custom_name_prefix: prefix,
          auto_start: true
        }).body
        raise(Error, body["msg"]) if body["status"] == "error"
        body
      end

      def history = json.get("/history").body

      def fetch_file(file)
        raw.get("/download/#{ERB::Util.url_encode(file)}").body
      end

      def delete(id, where: "done")
        json.post("/delete", {ids: [id], where:}).body
      end

      def delete_by_prefix(prefix)
        hist = history
        %w[queue done].each do |where|
          hist.fetch(where, []).each do |entry|
            next unless entry["custom_name_prefix"] == prefix
            next unless entry["url"]
            delete(entry["url"], where:)
          end
        end
      end

      private

      def json
        @json ||= build_connection do |conn|
          conn.request(:json)
          # MeTube serves JSON bodies as text/plain, so parse those too.
          conn.response(:json, content_type: /\b(json|plain)$/)
          conn.response(:raise_error)
          conn.response(:logger) unless Rails.env.test?
        end
      end

      def raw
        @raw ||= build_connection do |conn|
          conn.options.timeout = DOWNLOAD_TIMEOUT
          conn.response(:raise_error)
        end
      end

      def build_connection(&block)
        Faraday.new(url: base_url, &block)
      end

      def base_url = Rails.application.credentials.dig(:metube, :url)
    end
  end
end
