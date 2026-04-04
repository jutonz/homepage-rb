module Galleries
  class ProcessingImagesChannel <
    ApplicationCable::Channel
    def subscribed
      gallery = find_gallery
      if gallery
        @gallery = gallery
        stream_for(@gallery)
        transmit_unprocessed_ids
      else
        reject
      end
    end

    def sync
      transmit_unprocessed_ids
    end

    private

    def transmit_unprocessed_ids
      ids = Galleries::Image
        .where(gallery: @gallery)
        .unprocessed
        .pluck(:id)
      transmit({
        action: "reconcile",
        unprocessed_ids: ids
      })
    end

    def find_gallery
      Gallery
        .where(user: current_user)
        .find_by(id: params[:gallery_id])
    end
  end
end
