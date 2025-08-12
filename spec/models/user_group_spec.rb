# == Schema Information
#
# Table name: user_groups
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint           not null
#
# Indexes
#
#  index_user_groups_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
require "rails_helper"

RSpec.describe UserGroup do
  subject { build(:user_group) }

  it { is_expected.to belong_to(:owner) }
  it { is_expected.to have_many(:user_group_memberships).dependent(:destroy) }
  it { is_expected.to have_many(:users) }
  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
