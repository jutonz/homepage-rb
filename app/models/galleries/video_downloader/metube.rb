module Galleries
  module VideoDownloader
    class Metube
      def history = json.get("/history").body

      private

      def json
        @json ||= Faraday.new(url: base_url) do |conn|
          conn.request(:json)
          conn.response(:json)
          conn.response(:raise_error)
          conn.response(:logger) unless Rails.env.test?
        end
      end

      def base_url = Rails.application.credentials.dig(:metube, :url)
    end
  end
end
