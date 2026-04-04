module Galleries
  class ImageProcessingJob < ApplicationJob
    queue_as :background

    def perform(image)
      if image.file.variable?
        image.file.variant(:thumb).processed
      end

      image.calculate_perceptual_hash!
      image.update!(processed_at: Time.current)

      Turbo::StreamsChannel.broadcast_remove_to(
        image.gallery.processing_images_stream_name,
        target:
          "processing_image_#{image.id}"
      )
    end
  end
end
