require "rails_helper"

RSpec.describe Galleries::ImagePolicy do
  permissions :index?, :create? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      image = build(:galleries_image, gallery:)

      expect(described_class).to permit(user, image)
    end

    it "denies access when user does not own the gallery" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      image = build(:galleries_image, gallery:)

      expect(described_class).not_to permit(user, image)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      image = build(:galleries_image, gallery:)

      expect(described_class).not_to permit(nil, image)
    end
  end

  permissions :show?, :update?, :destroy? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      image = build(:galleries_image, gallery:)

      expect(described_class).to permit(user, image)
    end

    it "denies access when user does not own the gallery" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      image = build(:galleries_image, gallery:)

      expect(described_class).not_to permit(user, image)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      image = build(:galleries_image, gallery:)

      expect(described_class).not_to permit(nil, image)
    end
  end

  describe described_class::Scope do
    it "returns only images from galleries belonging to the user" do
      user = create(:user)
      other_user = create(:user)
      user_gallery1 = create(:gallery, user:)
      user_gallery2 = create(:gallery, user:)
      other_gallery = create(:gallery, user: other_user)
      user_image1 = create(:galleries_image, gallery: user_gallery1)
      user_image2 = create(:galleries_image, gallery: user_gallery2)
      create(:galleries_image, gallery: other_gallery)

      scope = described_class.new(user, Galleries::Image.all).resolve

      expect(scope).to contain_exactly(user_image1, user_image2)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create(:galleries_image, gallery:)

      scope = described_class.new(nil, Galleries::Image.all).resolve

      expect(scope).to be_empty
    end
  end
end
