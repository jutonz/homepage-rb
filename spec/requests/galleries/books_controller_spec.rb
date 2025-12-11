require "rails_helper"

RSpec.describe Galleries::BooksController do
  describe "index" do
    it "shows books for the gallery" do
      user = create(:user)
      gallery, other_gallery = create_pair(:gallery, user:)
      book = create(:galleries_book, gallery:)
      other_book = create(:galleries_book, gallery: other_gallery)
      login_as(user)

      get(gallery_books_path(gallery))

      expect(page).to have_book(book)
      expect(page).not_to have_book(other_book)
    end

    it "orders books by name" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book_b = create(:galleries_book, gallery:, name: "Book B")
      book_a = create(:galleries_book, gallery:, name: "Book A")
      login_as(user)

      get(gallery_books_path(gallery))

      book_links = page.all("[data-role=book]")
      expect(book_links[0].text).to include(book_a.name)
      expect(book_links[1].text).to include(book_b.name)
    end

    it "includes a count of the number of books" do
      user = create(:user)
      gallery = create(:gallery, user:)
      create_pair(:galleries_book, gallery:)
      login_as(user)

      get(gallery_books_path(gallery))

      expect(page).to have_text("2 books")
    end

    it "returns 404 when accessing books for gallery not owned by current user" do
      gallery = create(:gallery)
      create(:galleries_book, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(gallery_books_path(gallery))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "new" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)

      get(new_gallery_book_path(gallery))

      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
      expect(page).to have_link("Books", href: gallery_books_path(gallery))
    end

    it "returns 404 when accessing new book form for gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)

      get(new_gallery_book_path(gallery))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "create" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      login_as(user)
      params = {book: {name: "hello"}}

      post(gallery_books_path(gallery), params:)

      book = Galleries::Book.last
      expect(book.name).to eql("hello")
      expect(response).to redirect_to(gallery_book_path(gallery, book))
    end

    it "returns 404 when creating book in gallery not owned by current user" do
      gallery = create(:gallery)
      other_user = create(:user)
      login_as(other_user)
      params = {book: {name: "hello"}}

      post(gallery_books_path(gallery), params:)

      expect(response).to have_http_status(:not_found)
    end

  end

  describe "show" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      login_as(user)

      get(gallery_book_path(gallery, book))

      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
      expect(page).to have_link("Books", href: gallery_books_path(gallery))
    end

    it "returns 404 when viewing book from gallery not owned by current user" do
      gallery = create(:gallery)
      book = create(:galleries_book, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(gallery_book_path(gallery, book))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "update" do
    it "redirects" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:, name: "before")
      login_as(user)
      params = {book: {name: "after"}}

      put(gallery_book_path(gallery, book), params:)

      expect(response).to redirect_to(gallery_book_path(gallery, book))
      expect(book.reload.name).to eql("after")
    end

    it "returns 404 when updating book from gallery not owned by current user" do
      gallery = create(:gallery)
      book = create(:galleries_book, gallery:)
      other_user = create(:user)
      login_as(other_user)
      params = {book: {name: "updated"}}

      put(gallery_book_path(gallery, book), params:)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "edit" do
    it "has crumbs" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      login_as(user)

      get(edit_gallery_book_path(gallery, book))

      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Galleries", href: galleries_path)
      expect(page).to have_link(gallery.name, href: gallery_path(gallery))
      expect(page).to have_link("Books", href: gallery_books_path(gallery))
    end

    it "returns 404 when editing book from gallery not owned by current user" do
      gallery = create(:gallery)
      book = create(:galleries_book, gallery:)
      other_user = create(:user)
      login_as(other_user)

      get(edit_gallery_book_path(gallery, book))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "destroy" do
    it "returns 404 when destroying book from gallery not owned by current user" do
      gallery = create(:gallery)
      book = create(:galleries_book, gallery:)
      other_user = create(:user)
      login_as(other_user)

      delete(gallery_book_path(gallery, book))

      expect(response).to have_http_status(:not_found)
    end

    it "deletes the book" do
      user = create(:user)
      gallery = create(:gallery, user:)
      book = create(:galleries_book, gallery:)
      login_as(user)

      delete(gallery_book_path(gallery, book))

      expect(response).to redirect_to(gallery_books_path(gallery))
      expect(Galleries::Book.find_by(id: book)).to be_nil
    end
  end

  def have_book(book)
    have_css("[data-role=book]", text: book.name)
  end
end
