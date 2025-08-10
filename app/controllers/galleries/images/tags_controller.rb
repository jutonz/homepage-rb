module Galleries
  module Images
    class TagsController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @gallery = find_gallery
        @image = find_image
        @tag = authorize(find_tag)

        @image.add_tag(@tag)

        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to(
              gallery_image_path(@gallery, @image),
              notice: "Added tag"
            )
          end
        end
      end

      def destroy
        @gallery = find_gallery
        @image = find_image
        @tag = authorize(find_tag)

        @image.remove_tag(@tag)

        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to(
              gallery_image_path(@gallery, @image),
              notice: "Removed tag"
            )
          end
        end
      end

      private

      def find_gallery
        policy_scope(Gallery).find(params[:gallery_id])
      end

      def find_image
        policy_scope(Galleries::Image).where(gallery: @gallery).find(params[:image_id])
      end

      def find_tag
        policy_scope(Galleries::Tag).where(gallery: @gallery).find(params[:tag_id] || params[:id])
      end
    end
  end
end
