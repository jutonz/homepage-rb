# == Schema Information
#
# Table name: galleries_image_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image_id   :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_galleries_image_tags_on_image_id             (image_id)
#  index_galleries_image_tags_on_tag_id               (tag_id)
#  index_galleries_image_tags_on_tag_id_and_image_id  (tag_id,image_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (image_id => galleries_images.id)
#  fk_rails_...  (tag_id => galleries_tags.id)
#
FactoryBot.define do
  factory :galleries_image_tag, class: "Galleries::ImageTag" do
    image factory: :galleries_image
    tag factory: :galleries_tag
  end
end
