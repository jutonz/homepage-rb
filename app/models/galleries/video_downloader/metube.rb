# typed: strict

module Galleries
  module VideoDownloader
    class Metube
      # Raised when MeTube replies HTTP 200 but rejects the request in the
      # body, e.g. {"status" => "error", "msg" => "..."}.
      Error = Class.new(StandardError)

      DOWNLOAD_TIMEOUT = 600

      Entry = T.type_alias { T::Hash[String, T.nilable(String)] }

      History = T.type_alias { T::Hash[String, T::Array[Entry]] }
      private_constant(:History)

      sig { void }
      def initialize
        @json = T.let(nil, T.nilable(Faraday::Connection))
        @raw = T.let(nil, T.nilable(Faraday::Connection))
      end

      sig do
        params(url: String, prefix: String).returns(T::Hash[String, T.untyped])
      end
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
        T.cast(body, T::Hash[String, T.untyped])
      end

      sig { returns(History) }
      def history
        T.cast(json.get("/history").body, History)
      end

      sig { params(file: String).returns(String) }
      def fetch_file(file)
        T.cast(raw.get("/download/#{ERB::Util.url_encode(file)}").body, String)
      end

      sig do
        params(id: String, where: String).returns(T::Hash[String, T.untyped])
      end
      def delete(id, where: "done")
        T.cast(
          json.post("/delete", {ids: [id], where:}).body,
          T::Hash[String, T.untyped]
        )
      end

      sig { params(prefix: String).void }
      def delete_by_prefix(prefix)
        hist = history
        %w[queue done].each do |where|
          hist.fetch(where, []).each do |entry|
            next unless entry["custom_name_prefix"] == prefix

            url = entry["url"]
            delete(url, where:) if url
          end
        end
      end

      private

      sig { returns(Faraday::Connection) }
      def json
        @json ||= build_connection do |conn|
          conn.request(:json)
          # MeTube serves JSON bodies as text/plain, so parse those too.
          conn.response(:json, content_type: /\b(json|plain)$/)
          conn.response(:raise_error)
          conn.response(:logger) unless Rails.env.test?
        end
      end

      sig { returns(Faraday::Connection) }
      def raw
        @raw ||= build_connection do |conn|
          conn.options.timeout = DOWNLOAD_TIMEOUT
          conn.response(:raise_error)
        end
      end

      sig do
        params(
          block: T.proc.params(conn: Faraday::Connection).void
        ).returns(Faraday::Connection)
      end
      def build_connection(&block)
        Faraday.new(url: base_url, &block)
      end

      sig { returns(String) }
      def base_url
        T.cast(Rails.application.credentials.dig(:metube, :url), String)
      end
    end
  end
end
