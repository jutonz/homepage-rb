module Galleries
  class BulkUploadsController < ApplicationController
    before_action :ensure_authenticated!

    def new
      @gallery = find_gallery
      @bulk_upload = Galleries::BulkUpload.new(gallery: @gallery)
    end

    def create
      @gallery = find_gallery
      @bulk_upload =
        bulk_upload_params
          .to_h
          .merge({gallery: @gallery})
          .then { Galleries::BulkUpload.new(_1) }

      if @bulk_upload.save
        redirect_to @gallery, notice: "Bulk upload successful"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def find_gallery
      current_user.galleries.find(params[:gallery_id])
    end

    def bulk_upload_params
      params
        .require(:galleries_bulk_upload)
        .permit(files: [])
    end
  end
end
