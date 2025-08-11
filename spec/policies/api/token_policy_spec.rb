require "rails_helper"

RSpec.describe Api::TokenPolicy do
  describe "inheritance" do
    it "inherits from UserOwnedPolicy" do
      expect(described_class.superclass).to eq(UserOwnedPolicy)
    end
  end
end
