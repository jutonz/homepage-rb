require "rails_helper"

RSpec.describe UserGroups::InvitationsController, type: :request do
  describe "create" do
    it "creates invitation when user owns the group" do
      owner = create(:user)
      user_group = create(:user_group, owner:)
      email = "invitee@example.com"
      login_as(owner)

      expect {
        post user_group_invitations_path(user_group), params: {
          user_group_invitation: {email:}
        }
      }.to change { UserGroupInvitation.count }.by(1)

      invitation = UserGroupInvitation.last
      expect(invitation.user_group).to eq(user_group)
      expect(invitation.email).to eq(email)
      expect(invitation.invited_by).to eq(owner)
      expect(response).to redirect_to(user_group)
      expect(flash[:notice]).to include("Invitation sent to #{email}")
    end

    it "sends invitation email after creation" do
      owner = create(:user)
      user_group = create(:user_group, owner:)
      email = "invitee@example.com"

      login_as(owner)

      expect {
        post user_group_invitations_path(user_group), params: {
          user_group_invitation: {email:}
        }
      }.to have_enqueued_mail(UserGroupInvitationMailer, :invitation)

      expect(response).to redirect_to(user_group)
    end

    it "prevents non-owners from creating invitations" do
      owner = create(:user)
      non_owner = create(:user)
      user_group = create(:user_group, owner:)

      login_as(non_owner)

      post user_group_invitations_path(user_group), params: {
        user_group_invitation: {email: "test@example.com"}
      }

      expect(response).to have_http_status(:not_found)
    end

    it "handles validation errors gracefully" do
      owner = create(:user)
      user_group = create(:user_group, owner:)

      login_as(owner)

      post user_group_invitations_path(user_group), params: {
        user_group_invitation: {email: "invalid-email"}
      }

      expect(response).to redirect_to(user_group)
      expect(flash[:alert]).to include("Failed to send invitation")
    end

    it "handles duplicate invitations gracefully" do
      owner = create(:user)
      user_group = create(:user_group, owner:)
      email = "duplicate@example.com"

      create(:user_group_invitation, user_group:, email:, invited_by: owner)

      login_as(owner)

      post user_group_invitations_path(user_group), params: {
        user_group_invitation: {email:}
      }

      expect(response).to redirect_to(user_group)
      expect(flash[:alert]).to include("Failed to send invitation")
    end

    it "requires authentication" do
      user_group = create(:user_group)

      post user_group_invitations_path(user_group), params: {
        user_group_invitation: {email: "test@example.com"}
      }

      expect(response).to redirect_to(new_session_path)
    end
  end
end
