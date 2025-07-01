# == Schema Information
#
# Table name: galleries_social_media_links
#
#  id         :bigint           not null, primary key
#  platform   :string           not null
#  username   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_galleries_social_media_links_on_platform_and_username  (platform,username) UNIQUE
#  index_galleries_social_media_links_on_tag_id                 (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (tag_id => galleries_tags.id)
#
module Galleries
  class SocialMediaLink < ApplicationRecord
    belongs_to :tag
    has_one :gallery, through: :tag

    enum :platform, {
      instagram: "instagram",
      tiktok: "tiktok",
      url: "URL"
    }, validate: true

    normalizes :username, with: -> { it.strip.downcase }

    validates :platform, presence: true
    validates :username, presence: true, uniqueness: {scope: :platform}

    def href
      case platform
      when "instagram" then "https://instagram.com/#{username}"
      when "tiktok" then "https://tiktok.com/@#{username}"
      when "url" then username
      end
    end
  end
end
