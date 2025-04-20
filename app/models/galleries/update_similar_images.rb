module Galleries
  class UpdateSimilarImages
    def self.call(...) = new(...).call

    def initialize(image:)
      @image = image
    end

    def call
      ActiveRecord::Base.transaction do
        Galleries::ImageSimilarImage.where(parent_image: image).delete_all
        Galleries::ImageSimilarImage.insert_all(similar_images)
      end
    end

    private

    attr_reader :image

    def similar_images
      Galleries::SimilarImages
        .new(image:)
        .map.with_index do |similar_image, index|
          {
            parent_image_id: image.id,
            image_id: similar_image.id,
            position: index
          }
        end
    end
  end
end
