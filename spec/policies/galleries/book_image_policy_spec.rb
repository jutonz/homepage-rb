require "rails_helper"

RSpec.describe Galleries::BookImagePolicy do
  permissions :index?, :new? do
    it "grants access when user is present" do
      user = build(:user)
      gallery = build(:gallery)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).to permit(user, book_image)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).not_to permit(nil, book_image)
    end
  end

  permissions :create? do
    it "grants access when user owns the gallery through book" do
      user = build(:user)
      gallery = build(:gallery, user:)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).to permit(user, book_image)
    end

    it "denies access when user does not own the gallery" do
      user, other_user = build_pair(:user)
      gallery = build(:gallery, user: other_user)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).not_to permit(user, book_image)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).not_to permit(nil, book_image)
    end
  end

  permissions :show?, :update?, :destroy? do
    it "grants access when user owns the gallery through book" do
      user = build(:user)
      gallery = build(:gallery, user:)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).to permit(user, book_image)
    end

    it "denies access when user does not own the gallery" do
      user, other_user = build_pair(:user)
      gallery = build(:gallery, user: other_user)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).not_to permit(user, book_image)
    end

    it "denies access when user is nil" do
      gallery = build(:gallery)
      book = build(:galleries_book, gallery:)
      book_image = build(:galleries_book_image, book:)

      expect(described_class).not_to permit(nil, book_image)
    end
  end

  describe described_class::Scope do
    it "returns only book_images from galleries belonging to the user" do
      user, other_user = create_pair(:user)
      user_gallery1, user_gallery2 = create_pair(:gallery, user:)
      other_gallery = create(:gallery, user: other_user)
      user_book1 = create(:galleries_book, gallery: user_gallery1)
      user_book2 = create(:galleries_book, gallery: user_gallery2)
      other_book = create(:galleries_book, gallery: other_gallery)
      user_book_image1 = create(:galleries_book_image, book: user_book1)
      user_book_image2 = create(:galleries_book_image, book: user_book2)
      _other_book_image = create(:galleries_book_image, book: other_book)

      scope = described_class.new(user, Galleries::BookImage.all).resolve

      expect(scope).to contain_exactly(user_book_image1, user_book_image2)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      create(:galleries_book_image, book:)

      scope = described_class.new(nil, Galleries::BookImage.all).resolve

      expect(scope).to be_empty
    end
  end
end
