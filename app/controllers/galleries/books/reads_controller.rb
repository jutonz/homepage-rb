module Galleries
  module Books
    class ReadsController < ApplicationController
      before_action :ensure_authenticated!

      def show
        @gallery = find_gallery
        @book = authorize(find_book)
        @images = @book.images.includes(:file_attachment)
      end

      private

      def find_gallery
        policy_scope(Gallery).find(params[:gallery_id])
      end

      def find_book
        policy_scope(Galleries::Book)
          .where(gallery: @gallery)
          .find(params[:book_id])
      end
    end
  end
end
