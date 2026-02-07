# == Schema Information
#
# Table name: plants_plants
# Database name: primary
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  purchased_at   :datetime
#  purchased_from :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  key_image_id   :bigint
#  user_id        :bigint           not null
#
# Indexes
#
#  index_plants_plants_on_key_image_id  (key_image_id)
#  index_plants_plants_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (key_image_id => plants_plant_images.id)
#  fk_rails_...  (user_id => users.id)
#
module Plants
  class Plant < ApplicationRecord
    belongs_to(:user)
    belongs_to(
      :key_image,
      class_name: "Plants::PlantImage",
      optional: true
    )
    has_many(:plant_images, dependent: :destroy)

    has_rich_text :notes

    validates(:name, presence: true)
  end
end
