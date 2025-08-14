require "rails_helper"

RSpec.describe "User group invitations", type: :system do
  it "allows group owner to send invitations" do
    owner = create(:user)
    user_group = create(:user_group, owner:)
    login_as(owner)

    visit(user_group_path(user_group))

    expect(page).to have_content("Manage Invitations")

    within("[data-role=invitation-form]") do
      fill_in("Email", with: "invited@example.com")
      click_on("Send Invitation")
    end

    expect(page).to have_content("Invitation sent to invited@example.com")
    expect(page).to have_content("Pending")
  end

  it "shows validation errors for invalid email" do
    owner = create(:user)
    user_group = create(:user_group, owner:)
    login_as(owner)

    visit(user_group_path(user_group))

    within("[data-role=invitation-form]") do
      fill_in "Email", with: "invalid-email"
      click_on "Send Invitation"
    end

    expect(page).to have_content("Failed to send invitation")
  end

  it "allows cancelling pending invitations" do
    owner = create(:user)
    user_group = create(:user_group, owner:)
    invitation = create(
      :user_group_invitation,
      user_group:,
      invited_by: owner
    )
    login_as(owner)

    visit(user_group_path(user_group))

    within(
      "[data-role=pending-invitation]",
      text: invitation.email
    ) do
      expect(page).to have_content("Pending")
      click_on("Cancel")
    end

    expect(page).not_to have_css(
      "[data-role=pending-invitation]",
      text: invitation.email
    )
  end

  it "displays active invitation details" do
    owner = create(:user)
    user_group = create(:user_group, owner:)
    invitation = create(
      :user_group_invitation,
      user_group:,
      invited_by: owner,
      email: "invited@example.com"
    )

    visit(invitation_path(invitation.token))

    expect(page).to have_content("You're Invited!")
    expect(page).to have_content("#{owner.email} has invited you to join #{user_group.name}")
    expect(page).to have_content("Group Name: #{user_group.name}")
    expect(page).to have_content("Invited by: #{owner.email}")
    expect(page).to have_button("Accept Invitation")
  end

  it "displays expired invitation message" do
    owner = create(:user)
    user_group = create(:user_group, owner:)
    invitation = create(
      :user_group_invitation,
      :expired,
      user_group:,
      invited_by: owner
    )

    visit(invitation_path(invitation.token))

    expect(page).to have_content("Invitation Expired")
    expect(page).to have_content("This invitation to join #{user_group.name} has expired")
    expect(page).to have_content("Expired")
    expect(page).to have_content("Please contact #{owner.email} to request a new invitation")
    expect(page).not_to have_button("Accept Invitation")
  end

  it "displays already accepted invitation message" do
    owner = create(:user)
    user_group = create(:user_group, owner:)
    invitation = create(
      :user_group_invitation,
      :accepted,
      user_group:,
      invited_by: owner
    )

    visit(invitation_path(invitation.token))

    expect(page).to have_content("Already a Member")
    expect(page).to have_content("You're already a member of #{user_group.name}!")
    expect(page).to have_content("Member")
    expect(page).to have_link("View Group", href: user_group_path(user_group))
    expect(page).not_to have_button("Accept Invitation")
  end

  it "allows accepting valid invitations" do
    owner = create(:user)
    invitee = create(:user)
    user_group = create(:user_group)
    invitation = create(
      :user_group_invitation,
      user_group:,
      invited_by: owner,
      email: invitee.email
    )
    login_as(invitee)

    visit(invitation_path(invitation.token))

    click_on("Accept Invitation")

    expect(page).to have_content("Welcome to #{user_group.name}!")
    expect(current_path).to eq(user_group_path(user_group))
  end
end
