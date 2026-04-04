module Galleries
  class ProcessingImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def show
      @gallery = find_gallery
      authorize(
        @gallery,
        policy_class: Galleries::ProcessingImagesPolicy
      )
      @images =
        policy_scope(Galleries::Image)
          .where(gallery: @gallery, processed_at: nil)
          .includes(:file_attachment)
    end

    private

    def find_gallery
      policy_scope(Gallery)
        .find(params[:gallery_id])
    end
  end
end
