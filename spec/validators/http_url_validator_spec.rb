require "rails_helper"

RSpec.describe HttpUrlValidator, type: :model do
  subject do
    Class.new {
      include ActiveModel::Validations

      attr_accessor :url

      def self.name = "UrlHolder"

      validates(:url, http_url: true)
    }.new
  end

  it { is_expected.to allow_value(nil).for(:url) }
  it { is_expected.to allow_value("http://example.com/x").for(:url) }
  it { is_expected.to allow_value("https://example.com/x").for(:url) }
  it { is_expected.not_to allow_value("example.com/x").for(:url) }
  it { is_expected.not_to allow_value("https://a b.com").for(:url) }
  it { is_expected.not_to allow_value("https://").for(:url) }

  it "says the URL is not a valid http(s) URL" do
    is_expected.not_to allow_value("ftp://example.com/x")
      .for(:url)
      .with_message("is not a valid http(s) URL")
  end
end
