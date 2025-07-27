# == Schema Information
#
# Table name: galleries_auto_add_tags
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  auto_add_tag_id :bigint           not null
#  tag_id          :bigint           not null
#
# Indexes
#
#  index_galleries_auto_add_tags_on_auto_add_tag_id             (auto_add_tag_id)
#  index_galleries_auto_add_tags_on_tag_id                      (tag_id)
#  index_galleries_auto_add_tags_on_tag_id_and_auto_add_tag_id  (tag_id,auto_add_tag_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (auto_add_tag_id => galleries_tags.id)
#  fk_rails_...  (tag_id => galleries_tags.id)
#
FactoryBot.define do
  factory :galleries_auto_add_tag, class: "Galleries::AutoAddTag" do
    association :tag, factory: :galleries_tag
    association :auto_add_tag, factory: :galleries_tag
  end
end
