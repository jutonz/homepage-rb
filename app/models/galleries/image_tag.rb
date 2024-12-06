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
module Galleries
  class ImageTag < ApplicationRecord
    belongs_to :image, class_name: "Galleries::Image"
    belongs_to :tag,
      class_name: "Galleries::Tag",
      counter_cache: :image_tags_count

    validates :tag, uniqueness: {scope: :image_id}
  end
end
