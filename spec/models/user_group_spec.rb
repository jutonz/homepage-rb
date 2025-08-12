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
  it { is_expected.to belong_to(:owner) }
  it { is_expected.to have_many(:user_group_memberships) }
  it { is_expected.to have_many(:users) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:owner_id) }

  def setup_user_group
    create(:user_group)
  end

  it "creates a user group with owner" do
    user_group = setup_user_group

    expect(user_group.owner).to be_present
    expect(user_group.name).to be_present
  end

  def setup_user_group_with_members
    user_group = create(:user_group)
    user1 = create(:user)
    user2 = create(:user)
    create(:user_group_membership, user: user1, user_group:)
    create(:user_group_membership, user: user2, user_group:)
    [user_group, user1, user2]
  end

  it "has many users through memberships" do
    user_group, user1, user2 = setup_user_group_with_members

    expect(user_group.users).to contain_exactly(user1, user2)
  end

  def setup_membership_deletion_test
    user_group = create(:user_group)
    membership = create(:user_group_membership, user_group:)
    [user_group, membership]
  end

  it "destroys memberships when group is destroyed" do
    user_group, membership = setup_membership_deletion_test

    user_group.destroy!

    expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
