require "rails_helper"

RSpec.describe Galleries::Images::BookImagesController do
  describe "new" do
    it "shows available books" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      book1, book2 = create_pair(:galleries_book, gallery:)
      login_as(user)

      get(new_gallery_image_book_image_path(gallery, image))

      expect(response).to have_http_status(:success)
      expect(page).to have_text(book1.name)
      expect(page).to have_text(book2.name)
    end

    it "shows message when no books exist" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)

      get(new_gallery_image_book_image_path(gallery, image))

      expect(page).to have_text("No books available")
      expect(page).to have_link("Create a book")
    end

    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)

      get(new_gallery_image_book_image_path(gallery, image))

      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
      expect(page).to have_link(
        "Image",
        href: gallery_image_path(gallery, image)
      )
    end

    it "returns 404 when accessing image from gallery not owned by current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(new_gallery_image_book_image_path(gallery, image))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)

      get(new_gallery_image_book_image_path(gallery, image))

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "create" do
    it "adds image to book and redirects to image" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      book = create(:galleries_book, gallery:)
      login_as(user)
      params = {book_id: book.id}

      post(gallery_image_book_images_path(gallery, image), params:)

      expect(response).to redirect_to(gallery_image_path(gallery, image))
      book_image = Galleries::BookImage.last
      expect(book_image.image).to eql(image)
      expect(book_image.book).to eql(book)
      expect(book_image.order).to eql(1)
    end

    it "sets order to next available number" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image1, image2 = create_pair(:galleries_image, gallery:)
      book = create(:galleries_book, gallery:)
      create(:galleries_book_image, book:, image: image1, order: 5)
      login_as(user)
      params = {book_id: book.id}

      post(gallery_image_book_images_path(gallery, image2), params:)

      book_image = Galleries::BookImage.last
      expect(book_image.order).to eql(6)
    end

    it "returns 404 when adding to gallery not owned by current user" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      book = create(:galleries_book, gallery:)
      other_user = create(:user)
      login_as(other_user)
      params = {book_id: book.id}

      post(gallery_image_book_images_path(gallery, image), params:)

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      book = create(:galleries_book, gallery:)
      params = {book_id: book.id}

      post(gallery_image_book_images_path(gallery, image), params:)

      expect(response).to redirect_to(new_session_path)
    end
  end
end
