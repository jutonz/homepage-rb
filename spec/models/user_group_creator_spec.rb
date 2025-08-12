require "rails_helper"

RSpec.describe UserGroupCreator do
  describe ".call" do
    it "creates a user group and adds owner as member" do
      owner = create(:user)
      params = {name: "Test Group"}

      user_group = UserGroupCreator.call(owner:, params:)

      expect(user_group).to be_persisted
      expect(user_group.name).to eq("Test Group")
      expect(user_group.owner).to eq(owner)
      expect(user_group.users).to include(owner)
      expect(user_group.users_count).to eq(1)
    end

    it "handles validation errors" do
      owner = create(:user)
      params = {name: ""}

      user_group = UserGroupCreator.call(owner:, params:)

      expect(user_group).not_to be_persisted
      expect(user_group.errors[:name]).to include("can't be blank")
      expect(UserGroup.count).to eq(0)
      expect(UserGroupMembership.count).to eq(0)
    end

    it "creates owner membership" do
      owner = create(:user)
      params = {name: "Test Group"}

      user_group = UserGroupCreator.call(owner:, params:)

      expect(user_group).to be_persisted
      owner_membership = user_group.user_group_memberships.first
      expect(owner_membership).to be_present
      expect(owner_membership.user).to eq(owner)
    end
  end
end
