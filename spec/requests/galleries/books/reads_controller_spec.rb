require "rails_helper"

RSpec.describe Galleries::Books::ReadsController do
  describe "show" do
    it "displays all images without pagination" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      image1, image2 = create_pair(:galleries_image, gallery:)
      create(:galleries_book_image, book:, image: image1)
      create(:galleries_book_image, book:, image: image2)
      login_as(user)

      get(gallery_book_read_path(gallery, book))

      expect(page).to have_css(
        "[data-image-id='#{image1.id}']"
      )
      expect(page).to have_css(
        "[data-image-id='#{image2.id}']"
      )
    end

    it "displays images in correct order" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      image1 = create(:galleries_image, gallery:)
      image2 = create(:galleries_image, gallery:)
      image3 = create(:galleries_image, gallery:)
      create(
        :galleries_book_image,
        book:,
        image: image3,
        order: 3
      )
      create(
        :galleries_book_image,
        book:,
        image: image1,
        order: 1
      )
      create(
        :galleries_book_image,
        book:,
        image: image2,
        order: 2
      )
      login_as(user)

      get(gallery_book_read_path(gallery, book))

      images = page.all("[data-image-id]")
      expect(images[0]["data-image-id"]).to eql(
        image1.id.to_s
      )
      expect(images[1]["data-image-id"]).to eql(
        image2.id.to_s
      )
      expect(images[2]["data-image-id"]).to eql(
        image3.id.to_s
      )
    end

    it "displays empty state when no images" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      login_as(user)

      get(gallery_book_read_path(gallery, book))

      expect(page).to have_text("No images yet")
    end

    it "has back button to show page" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      login_as(user)

      get(gallery_book_read_path(gallery, book))

      expect(page).to have_link(
        "Back",
        href: gallery_book_path(gallery, book)
      )
    end

    it "has breadcrumb to show page" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      login_as(user)

      get(gallery_book_read_path(gallery, book))

      expect(page).to have_link(
        book.name,
        href: gallery_book_path(gallery, book)
      )
    end

    it "returns 404 for unauthorized access" do
      gallery = create(:gallery)
      book = create(:galleries_book, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(gallery_book_read_path(gallery, book))

      expect(response).to have_http_status(:not_found)
    end
  end
end
