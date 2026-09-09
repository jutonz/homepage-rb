# typed: true

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
          flash.now[:alert] = @book_image.errors.full_messages.to_sentence
          render :new, status: :unprocessable_content
        end
      end

      private

      def find_gallery
        GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
      end

      def find_image
        Galleries::ImagePolicy.scope_for(current_user)
          .where(gallery: @gallery)
          .find(params[:image_id])
      end

      def find_book
        Galleries::BookPolicy.scope_for(current_user)
          .where(gallery: @gallery)
          .find(params[:book_id])
      end

      def next_order
        (@book.book_images.maximum(:order) || 0) + 1
      end
    end
  end
end
