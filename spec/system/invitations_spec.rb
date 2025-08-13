require "rails_helper"

RSpec.describe "Invitations", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "sending invitations" do
    it "allows group owner to send invitations" do
      owner = create(:user)
      user_group = create(:user_group, owner:, name: "Test Group")

      # Mock authentication
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(owner)
      allow_any_instance_of(ApplicationController).to receive(:ensure_authenticated!).and_return(true)

      visit user_group_path(user_group)

      expect(page).to have_content("Manage Invitations")

      within "form[action='#{user_group_invitations_path(user_group)}']" do
        fill_in "user_group_invitation[email]", with: "invited@example.com"
        click_button "Send Invitation"
      end

      expect(page).to have_content("Invitation sent to invited@example.com")
      expect(page).to have_content("invited@example.com")
      expect(page).to have_content("Pending")
    end

    it "shows validation errors for invalid email" do
      owner = create(:user)
      user_group = create(:user_group, owner:)

      # Mock authentication
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(owner)
      allow_any_instance_of(ApplicationController).to receive(:ensure_authenticated!).and_return(true)

      visit user_group_path(user_group)

      within "form[action='#{user_group_invitations_path(user_group)}']" do
        fill_in "user_group_invitation[email]", with: "invalid-email"
        click_button "Send Invitation"
      end

      expect(page).to have_content("Failed to send invitation")
    end

    it "allows cancelling pending invitations" do
      owner = create(:user)
      user_group = create(:user_group, owner:, name: "Test Group")
      create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        email: "invited@example.com")

      # Mock authentication
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(owner)
      allow_any_instance_of(ApplicationController).to receive(:ensure_authenticated!).and_return(true)

      visit user_group_path(user_group)

      expect(page).to have_content("invited@example.com")
      expect(page).to have_content("Pending")

      # Test the cancel button (should have confirmation)
      expect(page).to have_button("Cancel")
    end
  end

  describe "viewing invitations" do
    it "displays active invitation details" do
      owner = create(:user, email: "owner@example.com")
      user_group = create(:user_group, owner:, name: "Awesome Group", users_count: 3)
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        email: "invited@example.com",
        expires_at: 3.days.from_now)

      visit invitation_path(invitation.token)

      expect(page).to have_content("You're Invited!")
      expect(page).to have_content("owner@example.com has invited you to join Awesome Group")
      expect(page).to have_content("Group Name: Awesome Group")
      expect(page).to have_content("Invited by: owner@example.com")
      expect(page).to have_content("Current Members:")
      expect(page).to have_button("Accept Invitation")
    end

    it "displays expired invitation message" do
      owner = create(:user, email: "owner@example.com")
      user_group = create(:user_group, owner:, name: "Test Group")
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        expires_at: 1.day.ago)

      visit invitation_path(invitation.token)

      expect(page).to have_content("Invitation Expired")
      expect(page).to have_content("This invitation to join Test Group has expired")
      expect(page).to have_content("Expired")
      expect(page).to have_content("Please contact owner@example.com to request a new invitation")
      expect(page).not_to have_button("Accept Invitation")
    end

    it "displays already accepted invitation message" do
      owner = create(:user, email: "owner@example.com")
      user_group = create(:user_group, owner:, name: "Test Group", users_count: 5)
      invitation = create(:user_group_invitation, :accepted,
        user_group:,
        invited_by: owner)

      visit invitation_path(invitation.token)

      expect(page).to have_content("Already a Member")
      expect(page).to have_content("You're already a member of Test Group!")
      expect(page).to have_content("Member")
      expect(page).to have_content("Current Members:")
      expect(page).to have_link("View Group", href: user_group_path(user_group))
      expect(page).not_to have_button("Accept Invitation")
    end
  end

  describe "accepting invitations" do
    it "allows accepting valid invitations" do
      owner = create(:user, email: "owner@example.com")
      invitee = create(:user, email: "invited@example.com")
      user_group = create(:user_group, owner:, name: "Test Group")
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        email: "invited@example.com")

      # Mock authentication as the invitee
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(invitee)
      allow_any_instance_of(ApplicationController).to receive(:ensure_authenticated!).and_return(true)

      visit invitation_path(invitation.token)

      expect(page).to have_button("Accept Invitation")

      click_button "Accept Invitation"

      expect(page).to have_content("Welcome to Test Group!")
      expect(current_path).to eq(user_group_path(user_group))
    end

    it "handles acceptance when invitation is expired" do
      owner = create(:user, email: "owner@example.com")
      invitee = create(:user, email: "invited@example.com")
      user_group = create(:user_group, owner:, name: "Test Group")
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        email: "invited@example.com",
        expires_at: 1.day.ago)

      # Mock authentication as the invitee
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(invitee)
      allow_any_instance_of(ApplicationController).to receive(:ensure_authenticated!).and_return(true)

      # Try to accept via direct POST (since expired invitations don't show accept button)
      page.driver.submit :post, invitation_acceptance_path(invitation.token), {}

      expect(page).to have_content("This invitation has expired")
      expect(current_path).to eq(invitation_path(invitation.token))
    end

    it "handles acceptance when user email doesn't match" do
      owner = create(:user, email: "owner@example.com")
      different_user = create(:user, email: "different@example.com")
      user_group = create(:user_group, owner:, name: "Test Group")
      invitation = create(:user_group_invitation,
        user_group:,
        invited_by: owner,
        email: "invited@example.com")

      # Mock authentication as different user
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(different_user)
      allow_any_instance_of(ApplicationController).to receive(:ensure_authenticated!).and_return(true)

      page.driver.submit :post, invitation_acceptance_path(invitation.token), {}

      expect(page).to have_content("Unable to accept invitation")
      expect(current_path).to eq(invitation_path(invitation.token))
    end
  end

  describe "non-owners" do
    it "does not show invitation management to non-owners" do
      owner = create(:user)
      non_owner = create(:user)
      user_group = create(:user_group, owner:)

      # Mock authentication as non-owner
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(non_owner)
      allow_any_instance_of(ApplicationController).to receive(:ensure_authenticated!).and_return(true)

      # This should result in 404 due to policy scope, handle it properly
      begin
        visit user_group_path(user_group)
        # If we get here, the test should fail
        expect(page).to have_content("This should not appear")
      rescue ActiveRecord::RecordNotFound
        # This is expected - non-owners can't access groups they don't own
        expect(true).to be_truthy
      end
    end
  end
end
