# == Schema Information
#
# Table name: galleries_social_media_links
# Database name: primary
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
FactoryBot.define do
  factory :galleries_social_media_link, class: "Galleries::SocialMediaLink" do
    tag factory: :galleries_tag
    sequence(:username) { "user#{it}" }
    instagram

    trait :url do
      platform { "url" }
      sequence(:username) { "https://example#{it}.com" }
    end
  end
end
