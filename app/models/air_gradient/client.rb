module AirGradient
  class Client
    def initialize(serial_no:)
      @url = url_from_serial(serial_no)
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
    attr_reader :url

    def url_from_serial(serial_no)
      "http://airgradient_#{serial_no}.local"
    end
  end
end
