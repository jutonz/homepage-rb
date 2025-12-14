require "webmock"

module FakeAirGradient
  extend WebMock::API

  def self.stub(url:, method:, path:)
    url = File.join(url, path)
    stub_request(method, url)
  end
end
