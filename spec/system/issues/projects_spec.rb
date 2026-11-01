require "rails_helper"

RSpec.describe "Project management", type: :system do
  it "creates, edits, and deletes a project from the issues index", :js do
    user = create(:user)
    login_as(user)

    visit(issues_path)
    click_link("Projects")

    expect(page).to have_content("No projects yet")

    click_link("New Project")
    fill_in("Name", with: "Infra")
    fill_in("Key", with: "INF")
    click_button("Create Project")

    expect(page).to have_content("Project was successfully created.")
    expect(page).to have_css("h1", text: "Infra")
    expect(page).to have_css("div.flex", text: /Key:\s+INF\b/)

    click_link("Edit")
    fill_in("Name", with: "Homepage")
    fill_in("Key", with: "HP")
    click_button("Update Project")

    expect(page).to have_content("Project was successfully updated.")
    expect(page).to have_css("h1", text: "Homepage")
    expect(page).to have_css("div.flex", text: /Key:\s+HP\b/)

    accept_confirm { click_button("Delete") }

    expect(page).to have_content("Project was successfully deleted.")
    expect(page).to have_content("No projects yet")
  end
end
