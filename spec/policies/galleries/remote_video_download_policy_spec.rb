require "rails_helper"

RSpec.describe Galleries::RemoteVideoDownloadPolicy do
  permissions :index?, :new?, :create? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      download = Galleries::RemoteVideoDownload.new(gallery:)

      expect(described_class).to permit(user, download)
    end

    it "denies access when user does not own the gallery" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      download = Galleries::RemoteVideoDownload.new(gallery:)

      expect(described_class).not_to permit(user, download)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      download = Galleries::RemoteVideoDownload.new(gallery:)

      expect(described_class).not_to permit(nil, download)
    end

    it "denies access when gallery is nil" do
      user = build(:user)
      download = Galleries::RemoteVideoDownload.new(gallery: nil)

      expect(described_class).not_to permit(user, download)
    end
  end
end
