require "rails_helper"

RSpec.describe Invitations::AcceptancesController, type: :request do
  describe "create" do
    it "accepts valid invitation when user exists" do
      user = create(:user)
      invitation = create(:user_group_invitation, email: user.email)
      login_as(user)

      post(invitation_acceptance_path(invitation.token))

      expect(response).to redirect_to(
        user_group_path(invitation.user_group)
      )
      expect(invitation.reload.accepted_at).to be_present
      expect(flash[:notice]).to include("Welcome to #{invitation.user_group.name}")
      membership = invitation.user_group.user_group_memberships.last
      expect(membership.user).to eq(user)
    end

    it "handles expired invitations" do
      user = create(:user)
      invitation = create(:user_group_invitation, :expired, email: user.email)
      login_as(user)

      post(invitation_acceptance_path(invitation.token))

      expect(response).to redirect_to(invitation_path(invitation.token))
      expect(invitation.reload.accepted_at).to be_nil
      expect(flash[:alert]).to include("expired")
    end

    it "handles already accepted invitations" do
      invitation = create(:user_group_invitation, :accepted)
      user = create(:user, email: invitation.email)
      login_as(user)

      post(invitation_acceptance_path(invitation.token))

      expect(response).to redirect_to(
        user_group_path(invitation.user_group)
      )
      expect(flash[:notice]).to include("already a member")
    end

    it "handles non-matching user email" do
      invitation = create(:user_group_invitation)
      different_user = create(:user, email: "different@example.com")
      login_as(different_user)

      post(invitation_acceptance_path(invitation.token))

      expect(response).to redirect_to(invitation_path(invitation.token))
      expect(invitation.reload.accepted_at).to be_nil
      expect(flash[:alert]).to include("Unable to accept invitation")
    end

    it "requires authentication" do
      invitation = create(:user_group_invitation)

      post(invitation_acceptance_path(invitation.token))

      expect(response).to redirect_to(new_session_path)
    end

    it "returns 404 for invalid token" do
      user = create(:user)
      login_as(user)

      post(invitation_acceptance_path("invalid-token"))

      expect(response).to have_http_status(:not_found)
    end
  end
end
