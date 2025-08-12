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
  subject { create(:user_group_membership) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:user_group) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:user_group_id) }
  it {
    is_expected.to validate_uniqueness_of(:user_id).scoped_to(:user_group_id)
  }

  def setup_membership
    create(:user_group_membership)
  end

  it "creates a valid membership" do
    membership = setup_membership

    expect(membership.user).to be_present
    expect(membership.user_group).to be_present
  end

  def setup_duplicate_membership_test
    user = create(:user)
    user_group = create(:user_group)
    create(:user_group_membership, user:, user_group:)
    [user, user_group]
  end

  it "prevents duplicate memberships for same user and group" do
    user, user_group = setup_duplicate_membership_test

    expect {
      create(:user_group_membership, user:, user_group:)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
