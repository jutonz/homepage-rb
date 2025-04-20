# == Schema Information
#
# Table name: galleries_image_similar_images
#
#  id              :bigint           not null, primary key
#  position        :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  image_id        :bigint           not null
#  parent_image_id :bigint           not null
#
# Indexes
#
#  idx_on_parent_image_id_position_ab63f755a1               (parent_image_id,position) UNIQUE
#  index_galleries_image_similar_images_on_image_id         (image_id)
#  index_galleries_image_similar_images_on_parent_image_id  (parent_image_id)
#
# Foreign Keys
#
#  fk_rails_...  (image_id => galleries_images.id)
#  fk_rails_...  (parent_image_id => galleries_images.id)
#
module Galleries
  class ImageSimilarImage < ActiveRecord::Base
    belongs_to :parent_image, class_name: "Galleries::Image"
    belongs_to :image, class_name: "Galleries::Image"

    validates :position, uniqueness: {scope: :parent_image_id}
  end
end
