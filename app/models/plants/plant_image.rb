# == Schema Information
#
# Table name: plants_plant_images
# Database name: primary
#
#  id         :bigint           not null, primary key
#  taken_at   :datetime
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
    has_one_attached(:file) do |file|
      file.variant(:thumb, resize_to_limit: [200, 200])
    end

    belongs_to(:plant)

    validates(:file, presence: true)
  end
end
