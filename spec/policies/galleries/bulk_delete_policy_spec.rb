require "rails_helper"

RSpec.describe Galleries::BulkDeletePolicy do
  permissions :create? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      bulk_delete = Galleries::BulkDelete.new(gallery:)

      expect(described_class).to permit(user, bulk_delete)
    end

    it "denies access when user does not own the gallery" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      bulk_delete = Galleries::BulkDelete.new(gallery:)

      expect(described_class).not_to permit(user, bulk_delete)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      bulk_delete = Galleries::BulkDelete.new(gallery:)

      expect(described_class).not_to permit(nil, bulk_delete)
    end

    it "denies access when gallery is nil" do
      user = build(:user)
      bulk_delete = Galleries::BulkDelete.new(gallery: nil)

      expect(described_class).not_to permit(user, bulk_delete)
    end
  end
end
