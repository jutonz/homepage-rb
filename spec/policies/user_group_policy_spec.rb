require "rails_helper"

RSpec.describe UserGroupPolicy do
  describe "inheritance" do
    it "inherits from ApplicationPolicy" do
      expect(described_class.superclass).to eq(ApplicationPolicy)
    end
  end

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:user_group) { create(:user_group, owner: user) }
  let(:other_user_group) { create(:user_group, owner: other_user) }

  describe "index?" do
    it "allows authenticated users" do
      policy = UserGroupPolicy.new(user, UserGroup)
      expect(policy.index?).to eq(true)
    end

    it "denies unauthenticated users" do
      policy = UserGroupPolicy.new(nil, UserGroup)
      expect(policy.index?).to eq(false)
    end
  end

  describe "show?" do
    it "allows owners to view their groups" do
      policy = UserGroupPolicy.new(user, user_group)
      expect(policy.show?).to eq(true)
    end

    it "denies non-owners" do
      policy = UserGroupPolicy.new(other_user, user_group)
      expect(policy.show?).to eq(false)
    end

    it "denies unauthenticated users" do
      policy = UserGroupPolicy.new(nil, user_group)
      expect(policy.show?).to eq(false)
    end
  end

  describe "create?" do
    it "allows authenticated users" do
      policy = UserGroupPolicy.new(user, UserGroup)
      expect(policy.create?).to eq(true)
    end

    it "denies unauthenticated users" do
      policy = UserGroupPolicy.new(nil, UserGroup)
      expect(policy.create?).to eq(false)
    end
  end

  describe "new?" do
    it "allows authenticated users" do
      policy = UserGroupPolicy.new(user, UserGroup)
      expect(policy.new?).to eq(true)
    end

    it "denies unauthenticated users" do
      policy = UserGroupPolicy.new(nil, UserGroup)
      expect(policy.new?).to eq(false)
    end
  end

  describe "update?" do
    it "allows owners to update their groups" do
      policy = UserGroupPolicy.new(user, user_group)
      expect(policy.update?).to eq(true)
    end

    it "denies non-owners" do
      policy = UserGroupPolicy.new(other_user, user_group)
      expect(policy.update?).to eq(false)
    end

    it "denies unauthenticated users" do
      policy = UserGroupPolicy.new(nil, user_group)
      expect(policy.update?).to eq(false)
    end
  end

  describe "edit?" do
    it "allows owners to edit their groups" do
      policy = UserGroupPolicy.new(user, user_group)
      expect(policy.edit?).to eq(true)
    end

    it "denies non-owners" do
      policy = UserGroupPolicy.new(other_user, user_group)
      expect(policy.edit?).to eq(false)
    end

    it "denies unauthenticated users" do
      policy = UserGroupPolicy.new(nil, user_group)
      expect(policy.edit?).to eq(false)
    end
  end

  describe "destroy?" do
    it "allows owners to destroy their groups" do
      policy = UserGroupPolicy.new(user, user_group)
      expect(policy.destroy?).to eq(true)
    end

    it "denies non-owners" do
      policy = UserGroupPolicy.new(other_user, user_group)
      expect(policy.destroy?).to eq(false)
    end

    it "denies unauthenticated users" do
      policy = UserGroupPolicy.new(nil, user_group)
      expect(policy.destroy?).to eq(false)
    end
  end

  describe "Scope" do
    it "returns only groups owned by the user" do
      user_groups = [user_group]
      other_groups = [other_user_group]

      scope = UserGroupPolicy::Scope.new(user, UserGroup).resolve

      expect(scope).to match_array(user_groups)
      expect(scope).not_to include(*other_groups)
    end

    it "returns no groups for unauthenticated users" do
      scope = UserGroupPolicy::Scope.new(nil, UserGroup).resolve

      expect(scope).to eq(UserGroup.none)
    end
  end
end
