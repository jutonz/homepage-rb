# == Schema Information
#
# Table name: plants_plant_images
# Database name: primary
#
#  id         :bigint           not null, primary key
#  taken_at   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  plant_id   :bigint           not null
#
# Indexes
#
#  index_plants_plant_images_on_plant_id  (plant_id)
#
# Foreign Keys
#
#  fk_rails_...  (plant_id => plants_plants.id)
#
module Plants
  class PlantImage < ApplicationRecord
    has_one_attached(:file)

    belongs_to(:plant)

    validates(:file, presence: true)
    validates(:taken_at, presence: true)
  end
end
