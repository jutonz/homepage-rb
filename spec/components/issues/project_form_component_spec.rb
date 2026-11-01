require "rails_helper"

RSpec.describe Issues::ProjectFormComponent, type: :component do
  it "renders the name and key fields and a create button" do
    project = build(:issues_project, user: nil)
    component = described_class.new(project:)

    render_inline(component)

    expect(page).to have_css("form[action='#{projects_path}']")
    expect(page).to have_css("input#project_name[autofocus]")
    expect(page).to have_field("Name")
    expect(page).to have_field("Key")
    expect(page).to have_button("Create Project")
  end

  it "fills the fields from the project and posts to it" do
    project = build_stubbed(:issues_project, name: "Infra", key: "INF")
    component = described_class.new(project:)

    render_inline(component)

    expect(page).to have_css("form[action='#{project_path(project)}']")
    expect(page).to have_field("Name", with: "Infra")
    expect(page).to have_field("Key", with: "INF")
    expect(page).to have_button("Update Project")
  end

  it "shows validation errors" do
    project = build(:issues_project, user: nil, name: "")
    project.validate
    component = described_class.new(project:)

    render_inline(component)

    expect(page).to have_content("can't be blank")
  end
end
