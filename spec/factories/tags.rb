# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_tags_on_gallery_id  (gallery_id)
#  index_tags_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :galleries_tag, class: "Galleries::Tag" do
    sequence(:name) { "Tag #{_1}" }
    gallery
    user
  end
end
