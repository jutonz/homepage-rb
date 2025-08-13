require "rails_helper"

RSpec.describe InvitationsController, type: :request do
  describe "GET /invitations/:token" do
    it "shows active invitation successfully" do
      owner = create(:user, email: "owner@example.com")
      user_group = create(:user_group, owner:, name: "Test Group", users_count: 5)
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        email: "invited@example.com",
        expires_at: 3.days.from_now,
        accepted_at: nil)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("You're Invited!")
      expect(response.body).to include("Test Group")
      expect(response.body).to include("owner@example.com")
      expect(response.body).to include("Group Name:")
      expect(response.body).to include("Invited by:")
      expect(response.body).to include("Current Members:")
      expect(response.body).to include("Accept Invitation")
    end

    it "shows expired invitation with appropriate messaging" do
      owner = create(:user, email: "owner@example.com")
      user_group = create(:user_group, owner:, name: "Expired Group")
      invitation = create(:user_group_invitation, :expired,
        user_group:,
        invited_by: owner)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("Invitation Expired")
      expect(response.body).to include("Expired Group")
      expect(response.body).to include("owner@example.com")
      expect(response.body).to include("Expired on:")
      expect(response.body).to include("Please contact")
    end

    it "shows already accepted invitation with member status" do
      owner = create(:user, email: "owner@example.com")
      user_group = create(:user_group, owner:, name: "Accepted Group", users_count: 8)
      invitation = create(:user_group_invitation, :accepted,
        user_group:,
        invited_by: owner)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("Already a Member")
      expect(response.body).to include("Accepted Group")
      expect(response.body).to include("Member")
      expect(response.body).to include("Accepted on:")
      expect(response.body).to include("View Group")
    end

    it "returns 404 for invalid token" do
      get invitation_path("invalid-token")

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent invitation ID" do
      get invitation_path("99999")

      expect(response).to have_http_status(:not_found)
    end

    it "shows invitation for recently created invitation" do
      invitation = create(:user_group_invitation)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("You're Invited!")
    end

    it "handles invitation close to expiration" do
      owner = create(:user)
      user_group = create(:user_group, owner:)
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        expires_at: 1.hour.from_now)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("You're Invited!")
      expect(response.body).to include("Accept Invitation")
      expect(response.body).not_to include("Expired")
    end

    it "shows correct page title for each state" do
      owner = create(:user)
      user_group = create(:user_group, owner:)

      # Active invitation
      active_invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        expires_at: 3.days.from_now,
        accepted_at: nil)
      get invitation_path(active_invitation.token)
      expect(response.body).to include("Group Invitation")

      # Expired invitation
      expired_invitation = create(:user_group_invitation, :expired,
        user_group:,
        invited_by: owner)
      get invitation_path(expired_invitation.token)
      expect(response.body).to include("Invitation Expired")

      # Accepted invitation
      accepted_invitation = create(:user_group_invitation, :accepted,
        user_group:,
        invited_by: owner)
      get invitation_path(accepted_invitation.token)
      expect(response.body).to include("Already a Member")
    end

    it "includes proper navigation breadcrumbs" do
      invitation = create(:user_group_invitation)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("Home")
      expect(response.body).to include(home_path)
    end

    it "shows invitation with special characters in group name" do
      owner = create(:user)
      user_group = create(:user_group, owner:, name: "Test & Development Group")
      invitation = create(:user_group_invitation, user_group:, invited_by: owner)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("Test &amp; Development Group")
    end

    it "shows invitation with long group name" do
      owner = create(:user)
      long_name = "A" * 100
      user_group = create(:user_group, owner:, name: long_name)
      invitation = create(:user_group_invitation, user_group:, invited_by: owner)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include(long_name)
    end

    it "includes correct HTTP headers" do
      invitation = create(:user_group_invitation)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.headers["Content-Type"]).to include("text/html")
    end

    it "handles invitation with zero member count" do
      owner = create(:user)
      user_group = create(:user_group, owner:, users_count: 0)
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        expires_at: 3.days.from_now,
        accepted_at: nil)

      get invitation_path(invitation.token)

      expect(response).to be_successful
      expect(response.body).to include("Current Members:")
      expect(response.body).to include("0")
    end
  end
end
