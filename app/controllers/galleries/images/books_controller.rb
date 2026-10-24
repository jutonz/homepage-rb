# typed: true

module Galleries
  module Images
    class BooksController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @gallery = find_gallery
        @image = @gallery.images.find(params[:image_id])
        @new_book = authorize(@gallery.books.new(book_params))
        @new_book.book_images.new(image: @image, order: 1)

        if @new_book.save
          name = @new_book.name.truncate(100)
          redirect_to(
            [@gallery, @image],
            status: :see_other,
            notice: "Created #{name} and added this image."
          )
        else
          @books = @gallery.books.order(:name)
          render(
            "galleries/images/book_images/new",
            status: :unprocessable_content
          )
        end
      end

      private

      def find_gallery
        GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
      end

      def book_params
        params.require(:book).permit(:name)
      end
    end
  end
end
