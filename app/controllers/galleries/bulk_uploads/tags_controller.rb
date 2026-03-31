module Galleries
  module BulkUploads
    class TagsController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @gallery = find_gallery
        authorize(@gallery, :show?)
        @tag = find_tag

        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to(
              new_gallery_bulk_upload_path(@gallery)
            )
          end
        end
      end

      def destroy
        @gallery = find_gallery
        authorize(@gallery, :show?)
        @tag = find_tag

        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to(
              new_gallery_bulk_upload_path(@gallery)
            )
          end
        end
      end

      private

      def find_gallery
        policy_scope(Gallery).find(
          params[:gallery_id]
        )
      end

      def find_tag
        @gallery.tags.find(
          params[:tag_id] || params[:id]
        )
      end
    end
  end
end
