module Galleries
  module Images
    class TagSearchesController < ApplicationController
      before_action :ensure_authenticated!

      def show
        @gallery = find_gallery
        @image = find_image
        @tag_search = TagSearch.new(
          gallery: @gallery,
          image: @image,
          query: tag_search_params[:query]
        )
      end

      private

      def find_gallery
        current_user.galleries.find(params[:gallery_id])
      end

      def find_image
        @gallery.images.find(params[:image_id])
      end

      def tag_search_params
        params.require(:images_tag_search).permit(:query)
      end
    end
  end
end
