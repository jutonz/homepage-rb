require "rails_helper"

RSpec.describe Galleries::ProcessingImagesPolicy do
  permissions :show? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)

      expect(described_class).to permit(user, gallery)
    end

    it "denies access when user does not own the gallery" do
      user = build(:user)
      gallery = build(:gallery, user: build(:user))

      expect(described_class).not_to permit(user, gallery)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)

      expect(described_class).not_to permit(nil, gallery)
    end
  end

  describe ".model" do
    it "resolves to Gallery rather than the policy name" do
      model = described_class.model

      expect(model).to eq(Gallery)
    end
  end
end
