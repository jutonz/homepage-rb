require "rails_helper"

RSpec.describe Galleries::AutoAddTagPolicy do
  permissions :new?, :create?, :destroy? do
    it "grants access when user owns the tag" do
      user = build(:user)
      gallery = build(:gallery, user:)
      tag = build(:galleries_tag, user:, gallery:)
      auto_add_tag_target = build(:galleries_tag, user:, gallery:)
      auto_add_tag = build(:galleries_auto_add_tag, tag:, auto_add_tag: auto_add_tag_target)

      expect(described_class).to permit(user, auto_add_tag)
    end

    it "denies access when user does not own the tag" do
      user = build(:user)
      other_user = build(:user)
      gallery = build(:gallery, user: other_user)
      tag = build(:galleries_tag, user: other_user, gallery:)
      auto_add_tag_target = build(:galleries_tag, user: other_user, gallery:)
      auto_add_tag = build(:galleries_auto_add_tag, tag:, auto_add_tag: auto_add_tag_target)

      expect(described_class).not_to permit(user, auto_add_tag)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      tag = build(:galleries_tag, gallery:)
      auto_add_tag_target = build(:galleries_tag, gallery:)
      auto_add_tag = build(:galleries_auto_add_tag, tag:, auto_add_tag: auto_add_tag_target)

      expect(described_class).not_to permit(nil, auto_add_tag)
    end
  end

  describe described_class::Scope do
    it "returns only auto add tags from tags belonging to the user" do
      user = create(:user)
      other_user = create(:user)
      user_gallery = create(:gallery, user:)
      other_gallery = create(:gallery, user: other_user)
      user_tag = create(:galleries_tag, user:, gallery: user_gallery)
      user_auto_tag = create(:galleries_tag, user:, gallery: user_gallery)
      other_tag = create(:galleries_tag, user: other_user, gallery: other_gallery)
      other_auto_tag = create(:galleries_tag, user: other_user, gallery: other_gallery)
      user_auto_add_tag = create(:galleries_auto_add_tag, tag: user_tag, auto_add_tag: user_auto_tag)
      create(:galleries_auto_add_tag, tag: other_tag, auto_add_tag: other_auto_tag)

      scope = described_class.new(user, Galleries::AutoAddTag.all).resolve

      expect(scope).to contain_exactly(user_auto_add_tag)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      gallery = create(:gallery, user:)
      tag = create(:galleries_tag, user:, gallery:)
      auto_tag = create(:galleries_tag, user:, gallery:)
      create(:galleries_auto_add_tag, tag:, auto_add_tag: auto_tag)

      scope = described_class.new(nil, Galleries::AutoAddTag.all).resolve

      expect(scope).to be_empty
    end
  end
end
