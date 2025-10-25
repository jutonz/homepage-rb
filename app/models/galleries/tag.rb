# == Schema Information
#
# Table name: galleries_tags
# Database name: primary
#
#  id               :bigint           not null, primary key
#  image_tags_count :integer          default(0), not null
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  gallery_id       :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_galleries_tags_on_gallery_id           (gallery_id)
#  index_galleries_tags_on_gallery_id_and_name  (gallery_id,name) UNIQUE
#  index_galleries_tags_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#  fk_rails_...  (user_id => users.id)
#

module Galleries
  class Tag < ApplicationRecord
    TAGGING_NEEDED_NAME = "tagging needed"

    belongs_to :gallery, counter_cache: true
    belongs_to :user
    has_many :image_tags,
      class_name: "Galleries::ImageTag",
      dependent: :destroy
    has_many :images, through: :image_tags
    has_many :social_media_links,
      class_name: "Galleries::SocialMediaLink",
      dependent: :destroy
    has_many :auto_add_tag_associations,
      class_name: "Galleries::AutoAddTag",
      dependent: :destroy
    has_many :auto_add_tags,
      through: :auto_add_tag_associations,
      source: :auto_add_tag

    validates :name,
      presence: true,
      uniqueness: {scope: :gallery_id}

    def self.tagging_needed(gallery)
      gallery
        .tags
        .create_with(user: gallery.user)
        .find_or_create_by(name: TAGGING_NEEDED_NAME)
    end

    def display_name
      "#{name} (#{image_tags_count})"
    end

    def tagging_needed? = name == TAGGING_NEEDED_NAME

    def available_auto_add_tags
      gallery.tags.where.not(id: [id] + auto_add_tag_ids)
    end
  end
end
