require "webmock"

module FakeMetube
  extend WebMock::API

  def self.stub(method:, path:)
    stub_request(method, File.join(base_url, path))
  end

  def self.base_url
    Rails.application.credentials.dig(:metube, :url)
  end
end
