module Galleries
  class ImageVariantJob < ApplicationJob
    queue_as :background

    def perform(image)
      if image.file.variable?
        image.file.variant(:thumb).processed
      end
    end
  end
end
