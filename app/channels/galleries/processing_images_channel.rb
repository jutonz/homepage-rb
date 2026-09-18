# typed: strict

module Galleries
  class ProcessingImagesChannel <
    ApplicationCable::Channel
    sig { void }
    def subscribed
      gallery = find_gallery
      if gallery
        @gallery = T.let(gallery, T.nilable(Gallery))
        stream_for(@gallery)
        transmit_unprocessed_ids
      else
        reject
      end
    end

    sig { void }
    def sync
      transmit_unprocessed_ids
    end

    private

    sig { void }
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

    sig { returns(T.nilable(Gallery)) }
    def find_gallery
      Gallery
        .where(user: current_user)
        .find_by(id: params[:gallery_id])
    end
  end
end
