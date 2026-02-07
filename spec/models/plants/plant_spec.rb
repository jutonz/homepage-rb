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
require "rails_helper"

RSpec.describe Plants::Plant do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:key_image).class_name("Plants::PlantImage").optional }

  it { is_expected.to have_rich_text(:notes) }

  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:plant)).to be_valid
  end
end
