# == Schema Information
#
# Table name: api_tokens
# Database name: primary
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_api_tokens_on_token             (token) UNIQUE
#  index_api_tokens_on_user_id           (user_id)
#  index_api_tokens_on_user_id_and_name  (user_id,name) UNIQUE
#
require "rails_helper"

RSpec.describe Api::Token do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:name) }

  describe "uniquness validations" do
    subject { build(:api_token) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:token).scoped_to(:user_id) }
  end

  describe "#generate_token" do
    it "generates a new token" do
      token = build(:api_token, token: nil)
      token.generate_token
      expect(token.token).to be_present
    end

    it "does not overwrite an existing token" do
      token = build(:api_token, token: "123")
      token.generate_token
      expect(token.token).to eql("123")
    end

    it "runs before validate" do
      token = build(:api_token, token: nil)
      token.validate
      expect(token.token).to be_present
    end
  end
end
