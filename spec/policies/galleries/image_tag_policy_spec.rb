require "rails_helper"

RSpec.describe Galleries::ImageTagPolicy do
  permissions :create?, :destroy? do
    it "grants access when user owns both the image's gallery and the tag" do
      user = build(:user)
      gallery = build(:gallery, user:)
      image = build(:galleries_image, gallery:)
      tag = build(:galleries_tag, user:, gallery:)
      image_tag = build(:galleries_image_tag, image:, tag:)

      expect(described_class).to permit(user, image_tag)
    end

    it "denies access when user does not own the image's gallery" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      image = build(:galleries_image, gallery:)
      tag = build(:galleries_tag, user:)
      image_tag = build(:galleries_image_tag, image:, tag:)

      expect(described_class).not_to permit(user, image_tag)
    end

    it "denies access when user does not own the tag" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user:)
      image = build(:galleries_image, gallery:)
      tag = build(:galleries_tag, user: other_user)
      image_tag = build(:galleries_image_tag, image:, tag:)

      expect(described_class).not_to permit(user, image_tag)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      image = build(:galleries_image, gallery:)
      tag = build(:galleries_tag)
      image_tag = build(:galleries_image_tag, image:, tag:)

      expect(described_class).not_to permit(nil, image_tag)
    end
  end

  describe described_class::Scope do
    it "returns only image_tags where user owns both image's gallery and tag" do
      user = create(:user)
      other_user = create(:user)
      user_gallery = create(:gallery, user:)
      other_gallery = create(:gallery, user: other_user)
      
      user_image = create(:galleries_image, gallery: user_gallery)
      other_image = create(:galleries_image, gallery: other_gallery)
      
      user_tag = create(:galleries_tag, user:, gallery: user_gallery)
      other_tag = create(:galleries_tag, user: other_user, gallery: other_gallery)
      
      valid_image_tag = create(:galleries_image_tag, image: user_image, tag: user_tag)
      create(:galleries_image_tag, image: other_image, tag: other_tag)
      create(:galleries_image_tag, image: user_image, tag: other_tag)

      scope = described_class.new(user, Galleries::ImageTag.all).resolve

      expect(scope).to contain_exactly(valid_image_tag)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      tag = create(:galleries_tag, user:, gallery:)
      create(:galleries_image_tag, image:, tag:)

      scope = described_class.new(nil, Galleries::ImageTag.all).resolve

      expect(scope).to be_empty
    end
  end
end