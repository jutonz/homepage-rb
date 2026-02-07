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
require "rails_helper"

RSpec.describe Plants::PlantImage do
  it { is_expected().to(belong_to(:plant)) }

  it { is_expected().to(validate_presence_of(:file)) }

  it "has a valid factory" do
    expect(build(:plants_plant_image)).to(be_valid())
  end
end
