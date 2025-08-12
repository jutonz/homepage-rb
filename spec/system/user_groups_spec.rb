require "rails_helper"

RSpec.describe "User Group management", type: :system do
  it "allows creating and managing user groups" do
    user = create(:user)
    login_as(user)

    visit home_path
    click_link "Manage User Groups"

    expect(page).to have_content("No user groups yet")
    expect(page).to have_content("Create your first user group")

    click_link "New User Group"

    fill_in "Name", with: "Development Team"
    click_button "Create User group"

    expect(page).to have_content("User group was successfully created")
    expect(page).to have_content("Development Team")
    expect(page).to have_content("1 member")
    expect(page).to have_content(user.email)

    click_link "Edit"

    fill_in "Name", with: "Software Development Team"
    click_button "Update User group"

    expect(page).to have_content("User group was successfully updated")
    expect(page).to have_content("Software Development Team")

    click_link "User Groups"

    expect(page).to have_content("Software Development Team")
    expect(page).to have_content("1 members")

    click_link "Software Development Team"
    click_button "Delete"

    expect(page).to have_content("User group was successfully destroyed")
    expect(page).to have_content("No user groups yet")
  end

  it "shows validation errors when creating invalid groups" do
    user = create(:user)
    login_as(user)

    visit new_user_group_path

    click_button "Create User group"

    expect(page).to have_content("can't be blank")
    expect(page).not_to have_content("User group was successfully created")
  end

  it "shows validation errors when updating with invalid data" do
    user = create(:user)
    user_group = create(:user_group, name: "Test Group", owner: user)
    login_as(user)

    visit edit_user_group_path(user_group)

    fill_in "Name", with: ""
    click_button "Update User group"

    expect(page).to have_content("can't be blank")
    expect(page).not_to have_content("User group was successfully updated")
  end

  it "displays user groups with member counts on index" do
    user = create(:user)
    other_user = create(:user)

    group1 = create(:user_group, name: "Developers", owner: user)
    create(:user_group, name: "Designers", owner: user)

    # Add additional member to first group
    create(:user_group_membership, user: other_user, user_group: group1)

    login_as(user)

    visit user_groups_path

    expect(page).to have_content("User Groups")
    expect(page).to have_css("[data-role='user_group']", count: 2)

    within("[data-role='user_group']", text: "Developers") do
      expect(page).to have_content("Developers")
      expect(page).to have_content("2 members")
    end

    within("[data-role='user_group']", text: "Designers") do
      expect(page).to have_content("Designers")
      expect(page).to have_content("1 members")
    end
  end

  it "shows group details with owner information" do
    user = create(:user, email: "owner@example.com")
    user_group = create(:user_group, name: "Marketing Team", owner: user)
    login_as(user)

    visit user_group_path(user_group)

    expect(page).to have_content("Marketing Team")
    expect(page).to have_content("1 member")
    expect(page).to have_content("Group Details")
    expect(page).to have_content("Name: Marketing Team")
    expect(page).to have_content("Owner: owner@example.com")
    expect(page).to have_content("Members: 1")
    expect(page).to have_content("Created:")
  end

  it "prevents non-owners from accessing other users' groups" do
    owner = create(:user)
    other_user = create(:user)
    user_group = create(:user_group, name: "Private Group", owner: owner)

    login_as(other_user)

    visit user_group_path(user_group)

    expect(page).to have_content("The page you were looking for doesn't exist")
  end

  it "includes breadcrumb navigation" do
    user = create(:user)
    user_group = create(:user_group, name: "Test Group", owner: user)
    login_as(user)

    visit user_group_path(user_group)

    expect(page).to have_link("Home", href: home_path)
    expect(page).to have_link("User Groups", href: user_groups_path)

    visit edit_user_group_path(user_group)

    expect(page).to have_link("Home", href: home_path)
    expect(page).to have_link("User Groups", href: user_groups_path)
    expect(page).to have_link("Test Group", href: user_group_path(user_group))

    visit new_user_group_path

    expect(page).to have_link("Home", href: home_path)
    expect(page).to have_link("User Groups", href: user_groups_path)
  end

  it "automatically includes owner as member with correct count" do
    user = create(:user)
    login_as(user)

    visit new_user_group_path

    fill_in "Name", with: "Auto Member Test"
    click_button "Create User group"

    # Check that owner is automatically a member
    expect(page).to have_content("1 member")

    # Navigate back to index to verify count there too
    click_link "User Groups"

    within("[data-role='user_group']", text: "Auto Member Test") do
      expect(page).to have_content("1 members")
    end
  end
end
