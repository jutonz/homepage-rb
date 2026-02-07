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
FactoryBot.define do
  factory(:plants_plant_image, class: "Plants::PlantImage") do
    plant()

    after(:build) do |plant_image|
      next if plant_image.file.attached?()

      plant_image.file.attach(
        io: StringIO.new("fake"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
    end

    trait :with_taken_at do
      taken_at { Time.zone.parse("2024-01-02 12:00:00") }
    end
  end
end
