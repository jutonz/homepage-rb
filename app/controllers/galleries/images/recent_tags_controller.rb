module Galleries
  module Images
    class RecentTagsController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def show
        @gallery = find_gallery
        @image = find_image
        authorize(@gallery, :show?)

        html =
          Galleries::Images::RecentTagsComponent
            .new(gallery: @gallery, image: @image)
            .render_in(view_context)

        render(html:)
      end

      private

      def find_gallery
        policy_scope(Gallery).find(params[:gallery_id])
      end

      def find_image
        policy_scope(Galleries::Image).where(gallery: @gallery).find(params[:image_id])
      end
    end
  end
end
