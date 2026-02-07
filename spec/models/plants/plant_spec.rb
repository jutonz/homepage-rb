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
#  user_id        :bigint           not null
#
# Indexes
#
#  index_plants_plants_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Plants::Plant do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:plants_plant)).to be_valid
  end
end
