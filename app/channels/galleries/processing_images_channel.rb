# typed: true

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
        .unprocessed
        .where(gallery: @gallery)
        .pluck(:id)
      transmit({
        action: "reconcile",
        unprocessed_ids: ids
      })
    end

    def find_gallery
      current_user = T.unsafe(self).current_user

      Gallery
        .where(user: current_user)
        .find_by(id: params[:gallery_id])
    end
  end
end
