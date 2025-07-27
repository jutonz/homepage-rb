# == Schema Information
#
# Table name: galleries_images
#
#  id              :bigint           not null, primary key
#  perceptual_hash :vector(64)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  gallery_id      :bigint           not null
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

    def similar_by_phash
      return self.class.none if perceptual_hash.nil?

      self.class
        .where(gallery_id:)
        .where.not(id:)
        .order(
          Arel.sql(
            "perceptual_hash <-> ? ASC",
            perceptual_hash.join(",").then { "[#{it}]" }
          )
        )
    end

    def similar_images = SimilarImagesQuery.call(image: self)

    def add_tag(*tags)
      tags = Array(tags)
      tags_relation = Tag.where(id: tags.map(&:id)).includes(:auto_add_tags)
      tags_to_add = Set.new(tags_relation + tags_relation.flat_map(&:auto_add_tags))

      tags_to_add.each do |tag|
        unless self.tags.include?(tag)
          self.tags << tag
        end
      end

      save!
      self.tags.each(&:auto_create_social_links)
    end

    def remove_tag(tag)
      image_tags.where(tag:).destroy_all
    end

    def video? = file.content_type.start_with?("video/")

    def calculate_perceptual_hash!
      return if video?

      file.open do |file|
        ImageHash
          .new(file.path)
          .binary_hash
          .then { hash_to_vector(it) }
          .then { update!(perceptual_hash: it) }
      end
    end

    def hash_to_vector(binary_hash)
      vector = Array.new(binary_hash.length)
      vector.length.times do |n|
        vector[n] = binary_hash[n].to_i
      end
      vector
    end
  end
end
