# typed: true

module Galleries
  module Books
    class ReadsController < ApplicationController
      before_action :ensure_authenticated!

      def show
        @gallery = find_gallery
        @book = authorize(find_book)
        @images = @book.images.includes(file_attachment: :blob)
      end

      private

      def find_gallery
        GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
      end

      def find_book
        Galleries::BookPolicy.scope_for(current_user)
          .where(gallery: @gallery)
          .find(params[:book_id])
      end
    end
  end
end
