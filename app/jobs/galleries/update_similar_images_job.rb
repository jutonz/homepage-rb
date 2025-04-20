module Galleries
  class UpdateSimilarImagesJob < ApplicationJob
    queue_as :background

    def perform(image)
      Galleries::UpdateSimilarImages.call(image:)
    end
  end
end
