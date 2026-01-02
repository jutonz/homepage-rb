module Galleries
  class BooksController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    PER_PAGE = 20

    def index
      @gallery = find_gallery
      authorize Galleries::Book
      @books =
        policy_scope(Galleries::Book)
          .where(gallery: @gallery)
          .order(:name)
    end

    def show
      @gallery = find_gallery
      @book = authorize(find_book)
      @images =
        @book
          .images
          .includes(:gallery)
          .includes(:file_attachment)
          .page(params[:page])
          .per(PER_PAGE)
    end

    def new
      @gallery = find_gallery
      @book = authorize(@gallery.books.new)
    end

    def create
      @gallery = find_gallery
      @book = authorize(@gallery.books.new(book_params))

      if @book.save
        redirect_to(
          [@gallery, @book],
          notice: "Book was successfully created."
        )
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @gallery = find_gallery
      @book = authorize(find_book)
    end

    def update
      @gallery = find_gallery
      @book = authorize(find_book)

      if @book.update(book_params)
        redirect_to(
          [@gallery, @book],
          notice: "Book was successfully updated."
        )
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @gallery = find_gallery
      @book = authorize(find_book)
      @book.destroy!

      redirect_to(
        gallery_books_path(@gallery),
        status: :see_other,
        notice: "Book was successfully destroyed."
      )
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def find_book
      policy_scope(Galleries::Book)
        .where(gallery: @gallery)
        .find(params[:id])
    end

    def book_params
      params.require(:book).permit(:name)
    end
  end
end
