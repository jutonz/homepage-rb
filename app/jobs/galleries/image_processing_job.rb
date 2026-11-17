# typed: strict

module Galleries
  class ImageProcessingJob < ApplicationJob
    queue_as :background

    VIDEO_POSTER_CONCURRENCY_KEY = "video_poster"

    # Solid Queue releases the lock after `duration` even while the job
    # still runs, so `duration` must exceed the slowest video poster.
    limits_concurrency(
      key: ->(image) { image.video? ? VIDEO_POSTER_CONCURRENCY_KEY : image },
      to: 1,
      duration: 15.minutes
    )

    sig { params(image: Galleries::Image).void }
    def perform(image)
      if image.file.variable?
        image.file.variant(:thumb).processed
      elsif image.file.previewable?
        image.poster.processed
      end

      image.calculate_perceptual_hash!
      image.update!(processed_at: Time.current)

      Turbo::StreamsChannel.broadcast_remove_to(
        T.must(image.gallery).processing_images_stream_name,
        target:
          "processing_image_#{image.id}"
      )
    end
  end
end
