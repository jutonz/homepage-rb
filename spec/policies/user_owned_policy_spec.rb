require "rails_helper"

RSpec.describe UserOwnedPolicy do
  permissions :index?, :create? do
    it "grants access when user is present" do
      user = build(:user)
      expect(described_class).to permit(user, Gallery)
    end

    it "denies access when user is nil" do
      expect(described_class).not_to permit(nil, Gallery)
    end
  end

  permissions :show?, :update?, :destroy? do
    it "grants access when user owns the record" do
      user = build(:user)
      gallery = build(:gallery, user:)

      expect(described_class).to permit(user, gallery)
    end

    it "denies access when user does not own the record" do
      user = build(:user)
      other_user = build(:user)
      other_users_gallery = build(:gallery, user: other_user)

      expect(described_class).not_to permit(user, other_users_gallery)
    end

    it "denies access when user is nil" do
      user = build(:user)
      gallery = build(:gallery, user:)

      expect(described_class).not_to permit(nil, gallery)
    end
  end

  permissions :new? do
    it "grants access when user is present" do
      user = build(:user)
      expect(described_class).to permit(user, Gallery)
    end

    it "denies access when user is nil" do
      expect(described_class).not_to permit(nil, Gallery)
    end
  end

  permissions :edit? do
    it "grants access when user owns the record" do
      user = build(:user)
      gallery = build(:gallery, user:)

      expect(described_class).to permit(user, gallery)
    end

    it "denies access when user does not own the record" do
      user = build(:user)
      other_user = build(:user)
      other_users_gallery = build(:gallery, user: other_user)

      expect(described_class).not_to permit(user, other_users_gallery)
    end

    it "denies access when user is nil" do
      user = build(:user)
      gallery = build(:gallery, user:)

      expect(described_class).not_to permit(nil, gallery)
    end
  end

  describe described_class::Scope do
    it "returns only records belonging to the user" do
      user = create(:user)
      other_user = create(:user)
      user_gallery1 = create(:gallery, user:)
      user_gallery2 = create(:gallery, user:)
      create(:gallery, user: other_user)

      scope = described_class.new(user, Gallery.all).resolve

      expect(scope).to contain_exactly(user_gallery1, user_gallery2)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      create(:gallery, user:)

      scope = described_class.new(nil, Gallery.all).resolve

      expect(scope).to be_empty
    end
  end
end
