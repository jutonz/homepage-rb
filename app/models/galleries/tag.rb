# == Schema Information
#
# Table name: galleries_tags
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

    belongs_to :gallery
    belongs_to :user
    has_many :image_tags,
      class_name: "Galleries::ImageTag",
      dependent: :destroy
    has_many :images, through: :image_tags
    has_many :social_media_links,
      class_name: "Galleries::SocialMediaLink",
      dependent: :destroy

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
      "#{name} (#{image_tags.size})"
    end

    def tagging_needed? = name == TAGGING_NEEDED_NAME

    AUTO_CREATE_SOCIAL_PREFIXES = {
      "IG:" => "instagram",
      "RD:" => "reddit",
      "TT:" => "tiktok"
    }
    def auto_create_social_links
      AUTO_CREATE_SOCIAL_PREFIXES.each do |(prefix, platform)|
        if name.start_with?(prefix)
          username = name.split(prefix).last
          social_media_links.find_or_create_by!(platform:, username:)
        end
      end
    end
  end
end
