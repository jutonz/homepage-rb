module Galleries
  module Images
    class TagsController < ApplicationController
      before_action :ensure_authenticated!

      def create
        @gallery = find_gallery
        @image = find_image
        @tag = find_tag

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
        @tag = find_tag

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
        current_user.galleries.find(params[:gallery_id])
      end

      def find_image
        @gallery.images.find(params[:image_id])
      end

      def find_tag
        @gallery.tags.find(params[:tag_id] || params[:id])
      end
    end
  end
end
