module Galleries
  class ImageVariantJob < ApplicationJob
    queue_as :background

    def perform(image)
      if image.file.variable?
        image.file.variant(:thumb).processed
      end

      image.update!(processing: false)

      Turbo::StreamsChannel.broadcast_replace_to(
        image,
        target: ActionView::RecordIdentifier.dom_id(
          image, :card
        ),
        renderable: Galleries::BulkUploads::ImageCardComponent.new(
          image:
        ),
        layout: false
      )
    end
  end
end
