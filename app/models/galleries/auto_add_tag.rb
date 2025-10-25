# == Schema Information
#
# Table name: galleries_auto_add_tags
# Database name: primary
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
module Galleries
  class AutoAddTag < ApplicationRecord
    belongs_to :tag, class_name: "Galleries::Tag"
    belongs_to :auto_add_tag, class_name: "Galleries::Tag"

    validates :auto_add_tag, uniqueness: {scope: :tag_id}
    validate :prevent_self_reference
    validate :prevent_circular_reference

    private

    def prevent_self_reference
      if tag_id == auto_add_tag_id
        errors.add(:auto_add_tag, "cannot be the same as the tag")
      end
    end

    def prevent_circular_reference
      return unless tag && auto_add_tag

      if auto_add_tag.auto_add_tags.include?(tag)
        errors.add(:auto_add_tag, "would create a circular reference")
      end
    end
  end
end
