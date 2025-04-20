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
      cluster =
        Galleries::Image
          .joins(:tags)
          .where(tags: {id: image.tag_ids})
          .distinct
          .where.not(id: image.id)

      this_weighted_tags = weighted_tags(image)

      cluster.sort_by do |other|
        other_weighted_tags = weighted_tags(other)

        (this_weighted_tags.keys & other_weighted_tags.keys).sum do |tag|
          this_weighted_tags[tag] * other_weighted_tags[tag]
        end
      end.reverse
    end

    def weighted_tags(image)
      image.tags.each_with_object({}) do |tag, acc|
        tag_count = tag.image_tags_count
        weight = tag_count.zero? ? 1.0 : 1.0 / tag_count
        acc[tag] = weight
      end
    end
  end
end
