require "rails_helper"

RSpec.describe UserGroupInvitationPolicy, type: :policy do
  permissions :create? do
    it "allows group owners to create invitations" do
      owner = build(:user)
      user_group = build(:user_group, owner:)
      invitation = build(:user_group_invitation, user_group:)

      expect(described_class).to permit(owner, invitation)
    end

    it "denies non-owners from creating invitations" do
      owner, non_owner = build_pair(:user)
      user_group = build(:user_group, owner:)
      invitation = build(:user_group_invitation, user_group:)

      expect(described_class).not_to permit(non_owner, invitation)
    end

    it "denies anonymous users from creating invitations" do
      invitation = build(:user_group_invitation)
      expect(described_class).not_to permit(nil, invitation)
    end
  end

  permissions :show? do
    it "allows anyone to view invitations" do
      invitation = build(:user_group_invitation)

      expect(described_class).to permit(nil, invitation)
      expect(described_class).to permit(build(:user), invitation)
    end
  end

  describe described_class::Scope do
    it "returns invitations for groups owned by user" do
      owner, other_user = create_pair(:user)
      owned_group = create(:user_group, owner:)
      other_group = create(:user_group, owner: other_user)

      owned_invitation = create(:user_group_invitation, user_group: owned_group)
      create(:user_group_invitation, user_group: other_group)

      scope = described_class.new(owner, UserGroupInvitation).resolve

      expect(scope).to contain_exactly(owned_invitation)
    end

    it "returns empty scope for anonymous users" do
      create(:user_group_invitation)

      scope = described_class.new(nil, UserGroupInvitation).resolve

      expect(scope).to be_empty
    end
  end
end
