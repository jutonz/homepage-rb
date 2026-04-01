module Galleries
  class BulkTagsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def create
      @gallery = find_gallery
      @bulk_tag = authorize(
        Galleries::BulkTag.new(bulk_tag_params.merge(gallery: @gallery))
      )

      redirect_params = existing_query_params
      ids = Array(@bulk_tag.image_ids).compact_blank
      if ids.present?
        redirect_params = redirect_params.merge(
          "selected_ids" => ids
        )
      end

      if @bulk_tag.save
        redirect_to(
          gallery_path(@gallery, **redirect_params),
          notice: "Tag added to selected images"
        )
      else
        redirect_to(
          gallery_path(@gallery, **redirect_params),
          alert: "Could not add tag"
        )
      end
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def bulk_tag_params
      params.require(:bulk_tag)
        .permit(:tag_id, image_ids: [])
    end

    def existing_query_params
      request.query_parameters
    end
  end
end
