# == Schema Information
#
# Table name: user_group_memberships
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_group_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_user_group_memberships_on_user_group_id              (user_group_id)
#  index_user_group_memberships_on_user_id                    (user_id)
#  index_user_group_memberships_on_user_id_and_user_group_id  (user_id,user_group_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_group_id => user_groups.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe UserGroupMembership do
  subject { build(:user_group_membership) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:user_group) }
  it {
    is_expected.to validate_uniqueness_of(:user_id).scoped_to(:user_group_id)
  }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
