# typed: strict

module Galleries
  module Images
    class TagSearchesController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      sig { void }
      def show
        @gallery = T.let(find_gallery, T.nilable(Gallery))
        @image = T.let(find_image, T.nilable(Galleries::Image))
        authorize(@gallery, :show?)
        tag_search = TagSearch.new(
          gallery: @gallery,
          image: @image,
          query: tag_search_params[:query]
        )

        html =
          TagSearches::ResultsComponent
            .new(tag_search:)
            .render_in(view_context)

        render(html:)
      end

      private

      sig { returns(Gallery) }
      def find_gallery
        GalleryPolicy.scope_for(current_user).find(params[:gallery_id])
      end

      sig { returns(Galleries::Image) }
      def find_image
        Galleries::ImagePolicy.scope_for(current_user)
          .where(gallery: @gallery)
          .find(params[:image_id])
      end

      sig { returns(ActionController::Parameters) }
      def tag_search_params
        params.require(:tag_search).permit(:query, :image_id)
      end
    end
  end
end
