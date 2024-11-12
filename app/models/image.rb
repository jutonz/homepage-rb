# == Schema Information
#
# Table name: gallery_images
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#
# Indexes
#
#  index_gallery_images_on_gallery_id  (gallery_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#
class Image < ActiveRecord::Base
  self.table_name = "gallery_images"

  has_one_attached :file
  belongs_to :gallery
end
