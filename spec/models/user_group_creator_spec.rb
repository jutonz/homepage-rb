require "rails_helper"

RSpec.describe UserGroupCreator do
  describe ".call" do
    it "creates a user group and adds owner as member" do
      owner = create(:user)
      params = {name: "Test Group"}

      creator = UserGroupCreator.call(owner:, **params)

      expect(creator.success?).to eq(true)
      expect(creator.user_group).to be_persisted
      expect(creator.user_group.name).to eq("Test Group")
      expect(creator.user_group.owner).to eq(owner)
      expect(creator.user_group.users).to include(owner)
      expect(creator.user_group.users_count).to eq(1)
    end

    it "handles validation errors" do
      owner = create(:user)
      params = {name: ""}

      creator = UserGroupCreator.call(owner:, **params)

      expect(creator.success?).to eq(false)
      expect(creator.user_group.errors[:name]).to include("can't be blank")
      expect(UserGroup.count).to eq(0)
      expect(UserGroupMembership.count).to eq(0)
    end

    it "rolls back membership creation if group creation fails" do
      owner = create(:user)
      params = {name: ""}

      creator = UserGroupCreator.call(owner:, **params)

      expect(creator.success?).to eq(false)
      expect(UserGroup.count).to eq(0)
      expect(UserGroupMembership.count).to eq(0)
    end

    it "creates membership within same transaction" do
      owner = create(:user)
      params = {name: "Test Group"}

      creator = UserGroupCreator.call(owner:, **params)

      user_group = creator.user_group
      membership = user_group.user_group_memberships.find_by(user: owner)

      expect(membership).to be_present
      expect(membership.user_group).to eq(user_group)
      expect(membership.user).to eq(owner)
    end
  end
end
