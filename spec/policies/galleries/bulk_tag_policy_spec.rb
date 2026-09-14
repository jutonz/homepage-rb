require "rails_helper"

RSpec.describe Galleries::BulkTagPolicy do
  permissions :create? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      bulk_tag = Galleries::BulkTag.new(gallery:)

      expect(described_class).to permit(user, bulk_tag)
    end

    it "denies access when user does not own the gallery" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      bulk_tag = Galleries::BulkTag.new(gallery:)

      expect(described_class).not_to permit(user, bulk_tag)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      bulk_tag = Galleries::BulkTag.new(gallery:)

      expect(described_class).not_to permit(nil, bulk_tag)
    end

    it "denies access when gallery is nil" do
      user = build(:user)
      bulk_tag = Galleries::BulkTag.new(gallery: nil)

      expect(described_class).not_to permit(user, bulk_tag)
    end
  end
end
