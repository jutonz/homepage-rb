require "rails_helper"

RSpec.describe Galleries::BulkUploadPolicy do
  permissions :new?, :create? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      bulk_upload = Galleries::BulkUpload.new(gallery:)

      expect(described_class).to permit(user, bulk_upload)
    end

    it "denies access when user does not own the gallery" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      bulk_upload = Galleries::BulkUpload.new(gallery:)

      expect(described_class).not_to permit(user, bulk_upload)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      bulk_upload = Galleries::BulkUpload.new(gallery:)

      expect(described_class).not_to permit(nil, bulk_upload)
    end

    it "denies access when gallery is nil" do
      user = build(:user)
      bulk_upload = Galleries::BulkUpload.new(gallery: nil)

      expect(described_class).not_to permit(user, bulk_upload)
    end
  end
end
