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
FactoryBot.define do
  factory :galleries_tag, class: "Galleries::Tag" do
    sequence(:name) { "Tag #{it}" }
    gallery
    user { instance.gallery.user || build(:user) }
  end
end
