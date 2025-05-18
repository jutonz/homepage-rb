module Galleries
  class ImagePerceptualHashJob < ApplicationJob
    queue_as :background

    def perform(image)
      image.calculate_perceptual_hash!
    end
  end
end
