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
#  added_by_id    :bigint           not null
#
# Indexes
#
#  index_plants_plants_on_added_by_id  (added_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (added_by_id => users.id)
#
require "rails_helper"

RSpec.describe Plants::Plant do
  it { is_expected.to belong_to(:added_by).class_name("User") }

  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:plants_plant)).to be_valid
  end
end
