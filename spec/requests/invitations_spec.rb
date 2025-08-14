require "rails_helper"

RSpec.describe InvitationsController, type: :request do
  describe "show" do
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
  end
end
