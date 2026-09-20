# typed: strict

module Galleries
  class PerceptualHashJob < ApplicationJob
    queue_as :background

    sig { params(image: Galleries::Image).void }
    def perform(image)
      image.calculate_perceptual_hash!
    end
  end
end
