require "rails_helper"

RSpec.describe UserGroupPolicy do
  describe "inheritance" do
    it "inherits from UserOwnedPolicy" do
      expect(described_class.superclass).to eq(UserOwnedPolicy)
    end
  end

  describe described_class::Scope do
    it "returns only groups owned by the user" do
      user = create(:user)
      other_user = create(:user)
      user_group = create(:user_group, owner: user)
      _other_user_group = create(:user_group, owner: other_user)

      scope = UserGroupPolicy::Scope.new(user, UserGroup).resolve

      expect(scope).to match_array([user_group])
    end

    it "returns no groups for unauthenticated users" do
      scope = UserGroupPolicy::Scope.new(nil, UserGroup).resolve

      expect(scope).to eq(UserGroup.none)
    end
  end
end
