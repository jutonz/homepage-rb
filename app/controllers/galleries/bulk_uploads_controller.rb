module Galleries
  class BulkUploadsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def new
      @gallery = find_gallery
      @bulk_upload = authorize(
        Galleries::BulkUpload.new(gallery: @gallery)
      )
      @tag_search = Galleries::TagSearch.new(
        gallery: @gallery
      )
    end

    def create
      @gallery = find_gallery
      @bulk_upload =
        bulk_upload_params
          .to_h
          .merge({gallery: @gallery})
          .then { authorize(Galleries::BulkUpload.new(it)) }

      if @bulk_upload.save
        render(
          turbo_stream: turbo_stream.append(
            "bulk-upload-cards",
            Galleries::BulkUploads::ImageCardComponent.new(
              image: @bulk_upload.image
            )
          )
        )
      else
        render(
          turbo_stream: turbo_stream.append(
            "bulk-upload-cards",
            helpers.tag.div(
              @bulk_upload.errors.full_messages.join(", "),
              class: "text-red-600 text-sm"
            )
          ),
          status: :unprocessable_content
        )
      end
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def bulk_upload_params
      params
        .require(:bulk_upload)
        .permit(:signed_id, tag_ids: [])
    end
  end
end
