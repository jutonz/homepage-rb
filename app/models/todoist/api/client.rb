# frozen_string_literal: true

module Todoist
  module Api
    class Client
      URL = "https://api.todoist.com"

      def self.get(...) = new.get(...)

      def self.post(...) = new.post(...)

      def initialize
        @connection = build_connection
      end

      def get(...) = connection.get(...)

      def post(...) = connection.post(...)

      private

      attr_reader :connection

      def build_connection
        Faraday.new(url: URL) do |conn|
          conn.headers["Authorization"] = "Bearer #{api_key}"
          conn.request(:json)
          conn.response(:json)
          conn.response(:raise_error)
          conn.response(:logger) unless Rails.env.test?
        end
      end

      def api_key
        Rails.application.credentials.todoist_api_key
      end
    end
  end
end
