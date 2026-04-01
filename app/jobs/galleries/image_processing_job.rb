module Galleries
  class ImageProcessingJob < ApplicationJob
    queue_as :background

    def perform(image)
      if image.file.variable?
        image.file.variant(:thumb).processed
      end

      image.calculate_perceptual_hash!
    end
  end
end
