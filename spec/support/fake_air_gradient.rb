require "webmock"

module FakeAirGradient
  extend WebMock::API

  def self.stub(serial_no:, method:, path:)
    host = "http://airgradient_#{serial_no}.local"
    url = File.join(host, path)
    stub_request(method, url)
  end
end
