require "rails_helper"

RSpec.describe Galleries::ImagePolicy do
  permissions :index?, :show?, :create?, :update?, :destroy? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      image = build(:galleries_image, gallery:)

      expect(described_class).to permit(user, image)
    end

    it "denies access when user does not own the gallery" do
      user, other_user = build_pair(:user)
      gallery = build(:gallery, user: other_user)
      image = build(:galleries_image, gallery:)

      expect(described_class).not_to permit(user, image)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      image = build(:galleries_image, gallery:)

      expect(described_class).not_to permit(nil, image)
    end

    it "denies access when the gallery is missing" do
      user = build(:user)
      image = build(:galleries_image, gallery: nil)

      expect(described_class).not_to permit(user, image)
    end
  end

  describe ".scope_for" do
    it "returns only images from galleries belonging to the user" do
      user, other_user = create_pair(:user)
      user_gallery1, user_gallery2 = create_pair(:gallery, user:)
      other_gallery = create(:gallery, user: other_user)
      user_image1 = create(:galleries_image, gallery: user_gallery1)
      user_image2 = create(:galleries_image, gallery: user_gallery2)
      _other_image = create(:galleries_image, gallery: other_gallery)

      policy_scope = described_class.scope_for(user)

      expect(policy_scope).to contain_exactly(user_image1, user_image2)
    end

    it "returns an empty collection when user is nil" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create(:galleries_image, gallery:)

      policy_scope = described_class.scope_for(nil)

      expect(policy_scope).to be_empty
    end
  end
end
