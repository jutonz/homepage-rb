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
      ids = similar_image_ids
      return Galleries::Image.none if ids.empty?

      distinct_image_ids = Galleries::Image.distinct.where(id: ids)
      Galleries::Image
        .includes(:gallery)
        .with_attached_file
        .where(id: distinct_image_ids)
        .order(Arel.sql("array_position(ARRAY[?], id)", ids))
    end

    def similar_image_ids
      Rails.cache.fetch(
        "similar-image-ids-#{image.id}",
        expires_in: 1.hour
      ) do
        cluster =
          Galleries::Image
            .distinct
            .joins(:tags)
            .where(tags: {id: image.tag_ids})
            .where.not(id: image.id)

        this_weighted_tags = weighted_tags(image)

        cluster.sort_by do |other|
          other_weighted_tags = weighted_tags(other)

          (this_weighted_tags.keys & other_weighted_tags.keys).sum do |tag|
            this_weighted_tags[tag] * other_weighted_tags[tag]
          end
        end.reverse.map(&:id)
      end
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
