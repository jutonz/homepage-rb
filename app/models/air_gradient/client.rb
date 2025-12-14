module AirGradient
  class Client
    def initialize(url:)
      @conn = Faraday.new(url:) do |builder|
        builder.response(:json)
        builder.response(:raise_error)
      end
    end

    def get(path)
      conn.get(path)
    end

    private

    attr_reader :conn
  end
end
