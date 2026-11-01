require "rails_helper"

RSpec.describe Issues::ProjectsController do
  def row_texts
    page.all("[data-role=project]").map { it.text.squish }
  end

  describe "index" do
    it "redirects a signed-out visitor to sign in" do
      get(projects_path)

      expect(response).to redirect_to(new_session_path)
      expect(session[:return_to]).to eql(projects_path)
    end

    it "lists only my projects with their keys" do
      me, them = create_pair(:user)
      mine = create(:issues_project, user: me, name: "Mine", key: "MY")
      theirs = create(:issues_project, user: them, name: "Theirs")
      login_as(me)

      get(projects_path)

      expect(page).to have_link(href: project_path(mine))
      expect(row_texts).to eq(["MY Mine"])
      expect(page).not_to have_content(theirs.name)
      expect(page).not_to have_content("No projects yet")
    end

    it "lists projects by name" do
      user = create(:user)
      create(:issues_project, user:, name: "Beta", key: "B")
      create(:issues_project, user:, name: "Alpha", key: "A")
      login_as(user)

      get(projects_path)

      expect(row_texts).to eq(["A Alpha", "B Beta"])
    end

    it "shows an empty state with a link to add a project" do
      user = create(:user)
      login_as(user)

      get(projects_path)

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "Projects")
      expect(page).to have_content("No projects yet")
      expect(page).to have_link("New Project", href: new_project_path)
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Issues", href: issues_path)
    end
  end

  describe "new" do
    it "redirects a signed-out visitor to sign in" do
      get(new_project_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the form" do
      user = create(:user)
      login_as(user)

      get(new_project_path)

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "New Project")
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Issues", href: issues_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_css("form[action='#{projects_path}']")
      expect(page).to have_field("Name")
      expect(page).to have_field("Key")
    end
  end

  describe "create" do
    it "redirects a signed-out visitor and creates nothing" do
      params = {project: {name: "Infra", key: "INF"}}

      post(projects_path, params:)

      expect(response).to redirect_to(new_session_path)
      expect(Issues::Project.count).to eq(0)
    end

    it "creates a trimmed project for the current user" do
      user = create(:user)
      login_as(user)
      params = {project: {name: "  Infra  ", key: "  In-Fra  "}}

      post(projects_path, params:)

      project = Issues::Project.last
      expect(response).to redirect_to(project_path(project))
      expect(flash[:notice]).to eq("Project was successfully created.")
      expect(project.user).to eq(user)
      expect(project.name).to eq("Infra")
      expect(project.key).to eq("In-Fra")
    end

    it "rejects a blank name and keeps the key" do
      user = create(:user)
      login_as(user)
      params = {project: {name: "", key: "INF"}}

      post(projects_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("can't be blank")
      expect(page).to have_field("Key", with: "INF")
      expect(Issues::Project.count).to eq(0)
    end

    it "rejects a key that differs from mine only in case" do
      user = create(:user)
      create(:issues_project, user:, key: "INF")
      login_as(user)
      params = {project: {name: "Infra", key: "inf"}}

      post(projects_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("has already been taken")
      expect(page).to have_field("Name", with: "Infra")
      expect(Issues::Project.count).to eq(1)
    end

    it "rejects a name over 255 characters and keeps it" do
      user = create(:user)
      login_as(user)
      name = "a" * 256
      params = {project: {name:, key: "INF"}}

      post(projects_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is too long")
      expect(page).to have_field("Name", with: name)
      expect(Issues::Project.count).to eq(0)
    end
  end

  describe "show" do
    it "redirects a signed-out visitor to sign in" do
      project = create(:issues_project)

      get(project_path(project))

      expect(response).to redirect_to(new_session_path)
    end

    it "shows my project with its key, edit, and delete" do
      user = create(:user)
      project = create(:issues_project, user:, name: "Infra", key: "INF")
      login_as(user)

      get(project_path(project))

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "Infra")
      expect(page).to have_css("div.flex", text: /Key:\s+INF\b/)
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Issues", href: issues_path)
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_link("Edit", href: edit_project_path(project))
      expect(page).to have_css(
        "form[action='#{project_path(project)}'] " \
        "input[name=_method][value=delete]",
        visible: :all
      )
      expect(page).to have_css(
        "form[action='#{project_path(project)}'] " \
        "button[data-turbo-confirm='Are you sure?']",
        text: "Delete"
      )
    end

    it "returns not found for another user's project" do
      user = create(:user)
      project = create(:issues_project)
      login_as(user)

      get(project_path(project))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "edit" do
    it "redirects a signed-out visitor to sign in" do
      project = create(:issues_project)

      get(edit_project_path(project))

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the form for my project" do
      user = create(:user)
      project = create(:issues_project, user:, name: "Infra", key: "INF")
      login_as(user)

      get(edit_project_path(project))

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "Edit Project")
      expect(page).to have_link("Projects", href: projects_path)
      expect(page).to have_link("Infra", href: project_path(project))
      expect(page).to have_css("form[action='#{project_path(project)}']")
      expect(page).to have_field("Name", with: "Infra")
      expect(page).to have_field("Key", with: "INF")
      expect(page).to have_button("Update Project")
    end

    it "returns not found for another user's project" do
      user = create(:user)
      project = create(:issues_project)
      login_as(user)

      get(edit_project_path(project))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "update" do
    it "redirects a signed-out visitor and changes nothing" do
      project = create(:issues_project, name: "Before")
      params = {project: {name: "After"}}

      patch(project_path(project), params:)

      expect(response).to redirect_to(new_session_path)
      expect(project.reload.name).to eq("Before")
    end

    it "updates my project and leaves others alone" do
      user = create(:user)
      project = create(:issues_project, user:, name: "Before", key: "B")
      bystander = create(:issues_project, user:, name: "Bystander")
      login_as(user)
      params = {project: {name: " After ", key: " A "}}

      patch(project_path(project), params:)

      project.reload
      expect(response).to redirect_to(project_path(project))
      expect(flash[:notice]).to eq("Project was successfully updated.")
      expect(project.name).to eq("After")
      expect(project.key).to eq("A")
      expect(bystander.reload.name).to eq("Bystander")
    end

    it "rejects a blank name and shows the stored name" do
      user = create(:user)
      project = create(:issues_project, user:, name: "Before", key: "B")
      login_as(user)
      params = {project: {name: "", key: "NEW"}}

      patch(project_path(project), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("can't be blank")
      expect(page).to have_css("h1", text: "Edit Project")
      expect(page).to have_link("Before", href: project_path(project))
      expect(page).to have_field("Key", with: "NEW")
      expect(project.reload.name).to eq("Before")
      expect(project.key).to eq("B")
    end

    it "rejects a name over 255 characters and keeps it" do
      user = create(:user)
      project = create(:issues_project, user:, name: "Before", key: "B")
      login_as(user)
      name = "a" * 256
      params = {project: {name:}}

      patch(project_path(project), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is too long")
      expect(page).to have_field("Name", with: name)
      expect(page).to have_link("Before", href: project_path(project))
      expect(project.reload.name).to eq("Before")
    end

    it "returns not found for another user's project" do
      user = create(:user)
      project = create(:issues_project, name: "Before")
      login_as(user)
      params = {project: {name: "After"}}

      patch(project_path(project), params:)

      expect(response).to have_http_status(:not_found)
      expect(project.reload.name).to eq("Before")
    end
  end

  describe "destroy" do
    it "redirects a signed-out visitor and deletes nothing" do
      project = create(:issues_project)

      delete(project_path(project))

      expect(response).to redirect_to(new_session_path)
      expect(Issues::Project.exists?(project.id)).to be(true)
    end

    it "deletes my project and leaves others alone" do
      user = create(:user)
      project = create(:issues_project, user:)
      bystander = create(:issues_project, user:)
      login_as(user)

      delete(project_path(project))

      expect(response).to redirect_to(projects_path)
      expect(response).to have_http_status(:see_other)
      expect(flash[:notice]).to eq("Project was successfully deleted.")
      expect(Issues::Project.exists?(project.id)).to be(false)
      expect(Issues::Project.exists?(bystander.id)).to be(true)
    end

    it "returns not found for another user's project" do
      user = create(:user)
      project = create(:issues_project)
      login_as(user)

      delete(project_path(project))

      expect(response).to have_http_status(:not_found)
      expect(Issues::Project.exists?(project.id)).to be(true)
    end
  end
end
