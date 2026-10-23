# typed: strict

module Galleries
  module Images
    class RecentTagsController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      sig { void }
      def show
        gallery = find_gallery
        @gallery = T.let(gallery, T.nilable(Gallery))
        image = find_image
        authorize(gallery, :show?)

        html =
          Galleries::Images::RecentTagsComponent
            .new(gallery:, image:)
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
    end
  end
end
