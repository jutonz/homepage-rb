require "rails_helper"

RSpec.describe Galleries::BookPolicy do
  permissions :index?, :create?, :new? do
    it "grants access when user is present" do
      user = build(:user)
      gallery = build(:gallery)
      book = build(:galleries_book, gallery:)

      expect(described_class).to permit(user, book)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      book = build(:galleries_book, gallery:)

      expect(described_class).not_to permit(nil, book)
    end
  end

  permissions :show?, :update?, :destroy? do
    it "grants access when user owns the gallery" do
      user = build(:user)
      gallery = build(:gallery, user:)
      book = build(:galleries_book, gallery:)

      expect(described_class).to permit(user, book)
    end

    it "denies access when user does not own the gallery" do
      user, other_user = build_pair(:user)
      gallery = build(:gallery, user: other_user)
      book = build(:galleries_book, gallery:)

      expect(described_class).not_to permit(user, book)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      book = build(:galleries_book, gallery:)

      expect(described_class).not_to permit(nil, book)
    end
  end

  describe described_class::Scope do
    it "returns only books from galleries belonging to the user" do
      user, other_user = create_pair(:user)
      user_gallery1, user_gallery2 = create_pair(:gallery, user:)
      other_gallery = create(:gallery, user: other_user)
      user_book1 = create(:galleries_book, gallery: user_gallery1)
      user_book2 = create(:galleries_book, gallery: user_gallery2)
      _other_book = create(:galleries_book, gallery: other_gallery)

      scope = described_class.new(user, Galleries::Book.all).resolve

      expect(scope).to contain_exactly(user_book1, user_book2)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create(:galleries_book, gallery:)

      scope = described_class.new(nil, Galleries::Book.all).resolve

      expect(scope).to be_empty
    end
  end
end
