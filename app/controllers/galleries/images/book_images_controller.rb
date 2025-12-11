module Galleries
  module Images
    class BookImagesController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def new
        @gallery = find_gallery
        @image = find_image
        authorize(Galleries::BookImage)
        @books = @gallery.books.order(:name)
      end

      def create
        @gallery = find_gallery
        @image = find_image
        @book = find_book
        @book_image = authorize(
          @book.book_images.new(
            image: @image,
            order: next_order
          )
        )

        if @book_image.save
          redirect_to(
            [@gallery, @image],
            notice: "Image added to book."
          )
        else
          @books = @gallery.books.order(:name)
          render :new, status: :unprocessable_content
        end
      end

      private

      def find_gallery
        policy_scope(Gallery).find(params[:gallery_id])
      end

      def find_image
        policy_scope(Galleries::Image)
          .where(gallery: @gallery)
          .find(params[:image_id])
      end

      def find_book
        policy_scope(Galleries::Book)
          .where(gallery: @gallery)
          .find(params[:book_id])
      end

      def next_order
        (@book.book_images.maximum(:order) || 0) + 1
      end
    end
  end
end
