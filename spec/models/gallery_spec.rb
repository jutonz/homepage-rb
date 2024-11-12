# == Schema Information
#
# Table name: galleries
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_galleries_on_name     (name) UNIQUE
#  index_galleries_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Gallery do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:images) }

  it { is_expected.to validate_presence_of(:name) }

  describe "uniqueness validation" do
    subject { build(:gallery) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  it "has a valid factory" do
    expect(create(:gallery)).to be_valid
  end
end