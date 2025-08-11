module Galleries
  module Images
    class TagSearchesController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def show
        @gallery = find_gallery
        @image = find_image
        authorize(@gallery, :show?)
        @tag_search = TagSearch.new(
          gallery: @gallery,
          image: @image,
          query: tag_search_params[:query]
        )

        respond_to do |format|
          format.turbo_stream
          format.html { render "galleries/images/show" }
        end
      end

      private

      def find_gallery
        policy_scope(Gallery).find(params[:gallery_id])
      end

      def find_image
        policy_scope(Galleries::Image).where(gallery: @gallery).find(params[:image_id])
      end

      def tag_search_params
        params.require(:tag_search).permit(:query, :image_id)
      end
    end
  end
end
