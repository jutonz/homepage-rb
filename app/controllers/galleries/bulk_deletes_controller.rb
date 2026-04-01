module Galleries
  class BulkDeletesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def create
      @gallery = find_gallery
      @bulk_delete = authorize(
        Galleries::BulkDelete.new(
          bulk_delete_params.merge(gallery: @gallery)
        )
      )

      if @bulk_delete.save
        redirect_to(
          gallery_path(@gallery, select: true),
          notice: "Selected images deleted"
        )
      else
        redirect_to(
          gallery_path(
            @gallery,
            select: true,
            selected_ids: @bulk_delete.image_ids
          ),
          alert: "Could not delete images"
        )
      end
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def bulk_delete_params
      params.require(:bulk_delete)
        .permit(image_ids: [])
    end
  end
end
