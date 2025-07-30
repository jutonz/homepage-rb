module FakeTodoist
  extend WebMock::API

  def self.stub(method, path)
    base = "https://api.todoist.com"
    url = File.join(base, path)
    stub_request(method, url)
  end
end
