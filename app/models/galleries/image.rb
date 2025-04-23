# == Schema Information
#
# Table name: galleries_images
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#
# Indexes
#
#  index_galleries_images_on_gallery_id  (gallery_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#
module Galleries
  class Image < ActiveRecord::Base
    has_one_attached :file do |file|
      file.variant(:thumb, resize_to_limit: [200, 200])
    end

    belongs_to :gallery
    has_many :image_tags,
      class_name: "Galleries::ImageTag",
      dependent: :destroy
    has_many :tags, through: :image_tags

    validates :file, presence: true

    def self.by_tags(tag_ids)
      joins(:tags)
        .where(tags: {id: tag_ids})
        .group(arel_table[:id])
        .having("COUNT(tags.id) = ?", Array(tag_ids).size)
        .distinct
    end

    def similar_images = SimilarImagesQuery.call(image: self)

    def add_tag(tag)
      unless tags.include?(tag)
        tags << tag
        save!
      end

      unless tag.tagging_needed?
        Galleries::UpdateSimilarImagesJob.perform_later(self)
      end
    end

    def remove_tag(tag)
      image_tags.where(tag:).destroy_all

      unless tag.tagging_needed?
        Galleries::UpdateSimilarImagesJob.perform_later(self)
      end
    end
  end
end
