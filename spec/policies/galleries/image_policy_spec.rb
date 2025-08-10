require "rails_helper"

RSpec.describe Galleries::ImagePolicy do
  describe "index?" do
    it "returns true when user owns the gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.index?).to be(true)
    end

    it "returns false when user does not own the gallery" do
      user = create(:user)
      other_user = create(:user)
      gallery = create(:gallery, user: other_user)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.index?).to be(false)
    end

    it "returns false when user is nil" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(nil, image)

      expect(policy.index?).to be(false)
    end
  end

  describe "show?" do
    it "returns true when user owns the gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.show?).to be(true)
    end

    it "returns false when user does not own the gallery" do
      user = create(:user)
      other_user = create(:user)
      gallery = create(:gallery, user: other_user)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.show?).to be(false)
    end

    it "returns false when user is nil" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(nil, image)

      expect(policy.show?).to be(false)
    end
  end

  describe "create?" do
    it "returns true when user owns the gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.create?).to be(true)
    end

    it "returns false when user does not own the gallery" do
      user = create(:user)
      other_user = create(:user)
      gallery = create(:gallery, user: other_user)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.create?).to be(false)
    end

    it "returns false when user is nil" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(nil, image)

      expect(policy.create?).to be(false)
    end
  end

  describe "update?" do
    it "returns true when user owns the gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.update?).to be(true)
    end

    it "returns false when user does not own the gallery" do
      user = create(:user)
      other_user = create(:user)
      gallery = create(:gallery, user: other_user)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.update?).to be(false)
    end

    it "returns false when user is nil" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(nil, image)

      expect(policy.update?).to be(false)
    end
  end

  describe "destroy?" do
    it "returns true when user owns the gallery" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.destroy?).to be(true)
    end

    it "returns false when user does not own the gallery" do
      user = create(:user)
      other_user = create(:user)
      gallery = create(:gallery, user: other_user)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(user, image)

      expect(policy.destroy?).to be(false)
    end

    it "returns false when user is nil" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      policy = described_class.new(nil, image)

      expect(policy.destroy?).to be(false)
    end
  end

  describe "Scope" do
    describe "#resolve" do
      it "returns images from galleries owned by user" do
        user = create(:user)
        other_user = create(:user)
        my_gallery = create(:gallery, user:)
        other_gallery = create(:gallery, user: other_user)
        my_image = create(:galleries_image, gallery: my_gallery)
        create(:galleries_image, gallery: other_gallery)
        scope = described_class::Scope.new(user, Galleries::Image.all).resolve

        expect(scope).to contain_exactly(my_image)
      end

      it "returns empty scope when user is nil" do
        gallery = create(:gallery)
        create(:galleries_image, gallery:)
        scope = described_class::Scope.new(nil, Galleries::Image.all).resolve

        expect(scope).to be_empty
      end
    end
  end
end
