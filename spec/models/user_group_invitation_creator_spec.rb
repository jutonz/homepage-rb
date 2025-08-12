require "rails_helper"

RSpec.describe UserGroupInvitationCreator, type: :model do
  describe ".call" do
    it "creates a UserGroupInvitation with required attributes" do
      user_group = create(:user_group)
      invited_by = create(:user)
      email = "test@example.com"

      invitation = UserGroupInvitationCreator.call(
        user_group:,
        email:,
        invited_by:
      )

      expect(invitation).to be_persisted
      expect(invitation.user_group).to eq(user_group)
      expect(invitation.email).to eq(email)
      expect(invitation.invited_by).to eq(invited_by)
      expect(invitation.token).to be_present
      expect(invitation.token.length).to eq(43)
      expect(invitation.expires_at).to be_within(1.minute).of(7.days.from_now)
      expect(invitation.accepted_at).to be_nil
    end

    it "generates unique tokens for multiple invitations" do
      user_group = create(:user_group)
      invited_by = create(:user)

      invitation1 = UserGroupInvitationCreator.call(
        user_group:,
        email: "test1@example.com",
        invited_by:
      )

      invitation2 = UserGroupInvitationCreator.call(
        user_group:,
        email: "test2@example.com",
        invited_by:
      )

      expect(invitation1.token).not_to eq(invitation2.token)
    end

    it "raises error when validation fails" do
      user_group = create(:user_group)
      invited_by = create(:user)

      expect {
        UserGroupInvitationCreator.call(
          user_group:,
          email: "invalid-email",
          invited_by:
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
