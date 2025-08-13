require "rails_helper"

RSpec.describe UserGroupInvitationPolicy, type: :policy do
  subject { UserGroupInvitationPolicy }

  permissions :create? do
    it "allows group owners to create invitations" do
      owner = create(:user)
      user_group = create(:user_group, owner:)
      invitation = UserGroupInvitation.new(user_group:)

      expect(subject).to permit(owner, invitation)
    end

    it "denies non-owners from creating invitations" do
      owner = create(:user)
      non_owner = create(:user)
      user_group = create(:user_group, owner:)
      invitation = UserGroupInvitation.new(user_group:)

      expect(subject).not_to permit(non_owner, invitation)
    end

    it "denies anonymous users from creating invitations" do
      user_group = create(:user_group)
      invitation = UserGroupInvitation.new(user_group:)

      expect(subject).not_to permit(nil, invitation)
    end
  end

  permissions :show? do
    it "allows anyone to view invitations" do
      invitation = create(:user_group_invitation)

      expect(subject).to permit(nil, invitation)
      expect(subject).to permit(create(:user), invitation)
    end
  end

  describe "Scope" do
    it "returns invitations for groups owned by user" do
      owner = create(:user)
      other_user = create(:user)

      owned_group = create(:user_group, owner:)
      other_group = create(:user_group, owner: other_user)

      owned_invitation = create(:user_group_invitation, user_group: owned_group)
      create(:user_group_invitation, user_group: other_group)

      scope = UserGroupInvitationPolicy::Scope.new(owner, UserGroupInvitation).resolve

      expect(scope).to contain_exactly(owned_invitation)
    end

    it "returns empty scope for anonymous users" do
      create(:user_group_invitation)

      scope = UserGroupInvitationPolicy::Scope.new(nil, UserGroupInvitation).resolve

      expect(scope).to be_empty
    end
  end
end
