require "rails_helper"

RSpec.describe Galleries::Images::BooksController do
  describe "create" do
    it "creates the book with the image first and redirects to it" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image, other_image = create_pair(:galleries_image, gallery:)
      bystander = create(:galleries_book, gallery:)
      create(
        :galleries_book_image,
        book: bystander,
        image: other_image,
        order: 5
      )
      login_as(user)
      params = {book: {name: "Summer 2026"}}

      post(gallery_image_books_path(gallery, image), params:)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(gallery_image_path(gallery, image))
      expect(flash[:notice]).to eql(
        "Created Summer 2026 and added this image."
      )
      book = gallery.books.find_by!(name: "Summer 2026")
      expect(book.book_images.sole.image).to eql(image)
      expect(book.book_images.sole.order).to eql(1)
      expect(bystander.book_images.sole.image).to eql(other_image)
      expect(bystander.book_images.sole.order).to eql(5)
      follow_redirect!
      expect(page).to have_text("In Books")
      expect(page).to have_text("Summer 2026")
    end

    it "truncates a very long name in the notice" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      login_as(user)
      name = "a" * 2500
      params = {book: {name:}}

      post(gallery_image_books_path(gallery, image), params:)

      expect(response).to have_http_status(:see_other)
      expect(gallery.books.find_by(name:)).to be_present
      expect(flash[:notice]).to eql(
        "Created #{"a" * 97}... and added this image."
      )
    end

    it "allows a name that an existing book has" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      create(:galleries_book, gallery:, name: "Summer")
      login_as(user)
      params = {book: {name: "Summer"}}

      post(gallery_image_books_path(gallery, image), params:)

      expect(response).to have_http_status(:see_other)
      expect(gallery.books.where(name: "Summer").count).to eql(2)
    end

    it "re-renders with the error on a blank name" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      create(:galleries_book, gallery:, name: "Book B")
      create(:galleries_book, gallery:, name: "Book A")
      login_as(user)
      params = {book: {name: ""}}

      post(gallery_image_books_path(gallery, image), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_css(
        "form[data-role=new-book]",
        text: "can't be blank"
      )
      selections = page.all("[data-role=book-selection] button")
      expect(selections.map { |button| button.text.squish }).to eql(
        ["Book A →", "Book B →"]
      )
      expect(gallery.books.count).to eql(2)
      expect(Galleries::BookImage.where(image:)).to be_empty
    end

    it "leaves no book when the image cannot join it" do
      user = create(:user)
      gallery = create(:gallery, user:)
      image = create(:galleries_image, gallery:)
      allow_any_instance_of(Galleries::BookImage)
        .to(receive(:valid?).and_return(false))
      login_as(user)
      params = {book: {name: "Summer 2026"}}

      post(gallery_image_books_path(gallery, image), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_css("form[data-role=new-book]")
      expect(Galleries::Book.where(name: "Summer 2026")).to be_empty
      expect(Galleries::BookImage.where(image:)).to be_empty
    end

    it "returns 404 for another user's gallery" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      login_as(create(:user))
      params = {book: {name: "Summer 2026"}}

      post(gallery_image_books_path(gallery, image), params:)

      expect(response).to have_http_status(:not_found)
      expect(gallery.books).to be_empty
    end

    it "returns 404 for an image from another of the user's galleries" do
      user = create(:user)
      gallery_a, gallery_b = create_pair(:gallery, user:)
      image = create(:galleries_image, gallery: gallery_b)
      login_as(user)
      params = {book: {name: "Summer 2026"}}

      post(gallery_image_books_path(gallery_a, image), params:)

      expect(response).to have_http_status(:not_found)
      expect(gallery_a.books).to be_empty
    end

    it "redirects a visitor to sign-in" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      params = {book: {name: "Summer 2026"}}

      post(gallery_image_books_path(gallery, image), params:)

      expect(response).to redirect_to(new_session_path)
      expect(gallery.books).to be_empty
    end
  end
end
