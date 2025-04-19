module Galleries
  class SimilarImages
    include Enumerable

    def initialize(image:)
      @image = image
    end

    def each
      similar_images.each do |similar_image|
        yield similar_image
      end
    end

    private

    attr_reader :image

    def similar_images
      Galleries::Image
        .joins(:tags)
        .where(tags: {id: image.tag_ids})
    end
  end
end
