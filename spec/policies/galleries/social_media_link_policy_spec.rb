require "rails_helper"

RSpec.describe Galleries::SocialMediaLinkPolicy do
  permissions :new?, :create?, :edit?, :update?, :destroy? do
    it "grants access when user owns the tag" do
      user = build(:user)
      gallery = build(:gallery, user:)
      tag = build(:galleries_tag, user:, gallery:)
      social_media_link = build(:galleries_social_media_link, tag:)

      expect(described_class).to permit(user, social_media_link)
    end

    it "denies access when user does not own the tag" do
      user, other_user = build_pair(:user)
      gallery = build(:gallery, user: other_user)
      tag = build(:galleries_tag, user: other_user, gallery:)
      social_media_link = build(:galleries_social_media_link, tag:)

      expect(described_class).not_to permit(user, social_media_link)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      tag = build(:galleries_tag, gallery:)
      social_media_link = build(:galleries_social_media_link, tag:)

      expect(described_class).not_to permit(nil, social_media_link)
    end
  end

  describe described_class::Scope do
    it "returns only social media links from tags belonging to the user" do
      user, other_user = create_pair(:user)
      user_gallery = create(:gallery, user:)
      other_gallery = create(:gallery, user: other_user)
      user_tag = create(:galleries_tag, user:, gallery: user_gallery)
      other_tag = create(:galleries_tag, user: other_user, gallery: other_gallery)
      user_link = create(:galleries_social_media_link, tag: user_tag)
      create(:galleries_social_media_link, tag: other_tag)

      scope = described_class.new(user, Galleries::SocialMediaLink.all).resolve

      expect(scope).to contain_exactly(user_link)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, user:, gallery:)
      create(:galleries_social_media_link, tag:)

      scope = described_class.new(nil, Galleries::SocialMediaLink.all).resolve

      expect(scope).to be_empty
    end
  end
end
