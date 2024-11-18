# == Schema Information
#
# Table name: galleries_tags
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
#  index_galleries_tags_on_gallery_id           (gallery_id)
#  index_galleries_tags_on_gallery_id_and_name  (gallery_id,name) UNIQUE
#  index_galleries_tags_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#  fk_rails_...  (user_id => users.id)
#

module Galleries
  class Tag < ApplicationRecord
    belongs_to :gallery
    belongs_to :user
    has_many :image_tags,
      class_name: "Galleries::ImageTag",
      dependent: :destroy
    has_many :images, through: :image_tags

    validates :name,
      presence: true,
      uniqueness: {scope: :gallery_id}

    def self.search(term, image:)
      if term.blank?
        all
      else
        where("name ILIKE ?", "%#{term}%")
      end
    end
  end
end
