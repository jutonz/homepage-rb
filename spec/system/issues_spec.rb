require "rails_helper"

RSpec.describe "Issue management", type: :system do
  it "creates, edits, and deletes an issue from a project", :js do
    user = create(:user)
    create(:issues_project, user:, name: "Homepage", key: "HOME")
    create(:issues_project, user:, name: "Infra", key: "INFRA")
    login_as(user)

    visit(home_path)
    click_link("View Projects")
    click_link("Homepage")

    expect(page).to have_content("No issues yet")

    click_link("New Issue")

    fill_in("Title", with: "Fix the login bug")
    fill_in_rich_text_area("issue_description", with: "Steps to reproduce")
    click_button("Create Issue")

    expect(page).to have_content("Issue was successfully created.")
    expect(page).to have_css("h1", text: "HOME-1 Fix the login bug")
    expect(page).to have_content("Steps to reproduce")

    click_link("Edit")
    fill_in("Title", with: "Fix the signup bug")
    select("Infra", from: "Project")
    fill_in_rich_text_area("issue_description", with: "New steps")
    click_button("Update Issue")

    expect(page).to have_content("Issue was successfully updated.")
    expect(page).to have_css("h1", text: "INFRA-1 Fix the signup bug")
    expect(page).to have_content("New steps")

    click_link("Infra")

    expect(page).to have_css(
      "[data-role=issue]", text: "INFRA-1 Fix the signup bug"
    )

    find("[data-role=issue]").click

    expect(page).to have_css("h1", text: "INFRA-1 Fix the signup bug")

    accept_confirm { click_button("Delete") }

    expect(page).to have_content("Issue was successfully deleted.")
    expect(page).to have_css("h1", text: "Infra")
    expect(page).to have_content("No issues yet")
  end

  it "asks me to create a project first when I have none" do
    user = create(:user)
    login_as(user)

    visit(new_issue_path)

    expect(page).to have_content("Create a project first")
    expect(page).to have_link("New Project", href: new_project_path)
    expect(page).not_to have_field("Title")
  end

  it "keeps the description when the title is blank", :js do
    user = create(:user)
    create(:issues_project, user:)
    login_as(user)

    visit(new_issue_path)
    fill_in_rich_text_area("issue_description", with: "Keep this text")
    click_button("Create Issue")

    expect(page).to have_content("can't be blank")
    expect(page).to have_css("trix-toolbar")
    expect(find("trix-editor")).to have_text("Keep this text")
  end

  it "keeps the description when an edit blanks the title", :js do
    user = create(:user)
    issue = create(:issue, user:, description: "Keep this text")
    login_as(user)

    visit(edit_issue_path(issue))
    fill_in("Title", with: "")
    click_button("Update Issue")

    expect(page).to have_content("can't be blank")
    expect(page).to have_css("trix-toolbar")
    expect(find("trix-editor")).to have_text("Keep this text")
  end
end
