require "rails_helper"

RSpec.describe IssuesController do
  def crumbs
    page.all("div.text-md a").map { [it.text, it[:href]] }
  end

  describe "index" do
    it "returns not found" do
      user = create(:user)
      login_as(user)

      get(issues_path)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "new" do
    it "redirects a signed-out visitor to sign in" do
      get(new_issue_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the form" do
      user = create(:user)
      create(:issues_project, user:)
      login_as(user)

      get(new_issue_path)

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "New Issue")
      expect(crumbs).to eq([["Home", home_path], ["Projects", projects_path]])
      expect(page).to have_field("Title")
    end

    it "preselects a project I own" do
      user = create(:user)
      create(:issues_project, user:, name: "Alpha")
      beta = create(:issues_project, user:, name: "Beta")
      login_as(user)

      get(new_issue_path(project_id: beta.id))

      options = page.all("select[name='issue[project_id]'] option")
      expect(options.map(&:text)).to eq(["Alpha", "Beta"])
      expect(page).to have_css(
        "select[name='issue[project_id]'] " \
        "option[selected][value='#{beta.id}']"
      )
      expect(crumbs).to eq(
        [
          ["Home", home_path],
          ["Projects", projects_path],
          ["Beta", project_path(beta)]
        ]
      )
    end

    it "ignores a project I do not own" do
      me, them = create_pair(:user)
      create(:issues_project, user: me, name: "Mine")
      theirs = create(:issues_project, user: them, name: "Theirs")
      login_as(me)

      get(new_issue_path(project_id: theirs.id))

      expect(response).to be_successful
      expect(page).to have_field("Title")
      options = page.all("select[name='issue[project_id]'] option")
      expect(options.map(&:text)).to eq(["Select a project", "Mine"])
      expect(page).not_to have_css(
        "select[name='issue[project_id]'] option[selected]"
      )
      expect(page).not_to have_content("Theirs")
      expect(crumbs).to eq([["Home", home_path], ["Projects", projects_path]])
    end

    it "lists only my projects by name, with a blank prompt first" do
      me, them = create_pair(:user)
      create(:issues_project, user: me, name: "Beta")
      create(:issues_project, user: me, name: "Alpha")
      create(:issues_project, user: them, name: "Theirs")
      login_as(me)

      get(new_issue_path)

      options = page.all("select[name='issue[project_id]'] option")
      expect(options.map(&:text)).to eq(["Select a project", "Alpha", "Beta"])
      expect(page).not_to have_content("Theirs")
    end

    it "asks me to create a project first when I have none" do
      user = create(:user)
      create(:issues_project, name: "Theirs")
      login_as(user)

      get(new_issue_path)

      expect(response).to be_successful
      expect(page).to have_content("Create a project first")
      expect(page).to have_link("New Project", href: new_project_path)
      expect(page).not_to have_field("Title")
      expect(page).not_to have_css("select")
    end
  end

  describe "create" do
    it "redirects a signed-out visitor and creates nothing" do
      params = {issue: {title: "Nope"}}

      post(issues_path, params:)

      expect(response).to redirect_to(new_session_path)
      expect(Issue.count).to eq(0)
    end

    it "creates an issue for the current user" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      params = {
        issue: {
          title: "Fix it",
          description: "<strong>Bold</strong> text",
          project_id: project.id
        }
      }

      post(issues_path, params:)

      issue = Issue.last
      expect(response).to redirect_to(issue_path(issue))
      expect(flash[:notice]).to eq("Issue was successfully created.")
      expect(issue.user).to eq(user)
      expect(issue.project).to eq(project)
      expect(issue.title).to eq("Fix it")
      expect(issue.description.to_plain_text).to include("Bold text")
    end

    it "defaults the status to backlog" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      params = {issue: {title: "Fix it", project_id: project.id}}

      post(issues_path, params:)

      issue = Issue.last
      expect(response).to redirect_to(issue_path(issue))
      expect(issue.status).to eq("backlog")
    end

    it "creates an issue with the chosen status" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      params = {
        issue: {title: "Fix it", status: "in_progress", project_id: project.id}
      }

      post(issues_path, params:)

      issue = Issue.last
      expect(response).to redirect_to(issue_path(issue))
      expect(issue.status).to eq("in_progress")
    end

    it "rejects a blank status and creates nothing" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      params = {issue: {title: "Fix it", status: "", project_id: project.id}}

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is not included in the list")
      expect(page).to have_field("Title", with: "Fix it")
      expect(Issue.count).to eq(0)
    end

    it "rejects a blank title and keeps the description" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      params = {
        issue: {
          title: "",
          description: "Keep this text",
          project_id: project.id
        }
      }

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("can't be blank")
      expect(page).to have_css(
        "input[name='issue[description]'][value*='Keep this text']",
        visible: :all
      )
      expect(Issue.count).to eq(0)
    end

    it "rejects a title over 255 characters and keeps it" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      title = "a" * 256
      params = {issue: {title:, project_id: project.id}}

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is too long")
      expect(page).to have_field("Title", with: title)
      expect(Issue.count).to eq(0)
    end

    it "rejects a project of another user and shows the form" do
      user = create(:user)
      create(:issues_project, user:, name: "Mine")
      theirs = create(:issues_project, name: "Theirs")
      login_as(user)
      params = {issue: {title: "Fix it", project_id: theirs.id}}

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_css(".issue_project span.error", text: "must exist")
      expect(page).to have_field("Title", with: "Fix it")
      expect(page).not_to have_content("Theirs")
      expect(crumbs).to eq([["Home", home_path], ["Projects", projects_path]])
      expect(Issue.count).to eq(0)
    end

    it "rejects a project that does not exist" do
      user = create(:user)
      create(:issues_project, user:)
      login_as(user)
      params = {issue: {title: "Fix it", project_id: 0}}

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_css(".issue_project span.error", text: "must exist")
      expect(Issue.count).to eq(0)
    end

    it "asks me to create a project first when I have none" do
      user = create(:user)
      login_as(user)
      params = {issue: {title: "Fix it"}}

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("Create a project first")
      expect(Issue.count).to eq(0)
    end
  end

  describe "show" do
    it "redirects a signed-out visitor to sign in" do
      issue = create(:issue)

      get(issue_path(issue))

      expect(response).to redirect_to(new_session_path)
    end

    it "shows my issue with its description" do
      user = create(:user)
      issue = create(
        :issue,
        user:,
        title: "Fix it",
        description: "<strong>Bold</strong> text"
      )
      login_as(user)

      get(issue_path(issue))

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "Fix it")
      expect(page).to have_css(".prose strong", text: "Bold")
      expect(crumbs).to eq(
        [
          ["Home", home_path],
          ["Projects", projects_path],
          [issue.project.name, project_path(issue.project)]
        ]
      )
    end

    it "shows the status pill between the header and the description" do
      user = create(:user)
      issue = create(
        :issue,
        user:,
        status: :in_progress,
        description: "Some text"
      )
      login_as(user)

      get(issue_path(issue))

      expect(page).to have_css("div.mb-4 span", text: "In Progress")
      expect(page.native.to_html).to match(
        /<h1.*In Progress.*class="prose/m
      )
    end

    it "shows my issue without a description" do
      user = create(:user)
      issue = create(:issue, user:, title: "Fix it")
      login_as(user)

      get(issue_path(issue))

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "Fix it")
      expect(page).not_to have_css(".prose")
    end

    it "returns not found for another user's issue" do
      user = create(:user)
      issue = create(:issue)
      login_as(user)

      get(issue_path(issue))

      expect(response).to have_http_status(:not_found)
    end

    it "links to edit and offers delete" do
      user = create(:user)
      issue = create(:issue, user:)
      login_as(user)

      get(issue_path(issue))

      expect(page).to have_link("Edit", href: edit_issue_path(issue))
      expect(page).to have_css(
        "form[action='#{issue_path(issue)}'] " \
        "input[name=_method][value=delete]",
        visible: :all
      )
      expect(page).to have_css(
        "form[action='#{issue_path(issue)}'] " \
        "button[data-turbo-confirm='Are you sure?']",
        text: "Delete"
      )
    end
  end

  describe "edit" do
    it "redirects a signed-out visitor to sign in" do
      issue = create(:issue)

      get(edit_issue_path(issue))

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the form for my issue" do
      user = create(:user)
      issue = create(:issue, user:, title: "Fix it")
      login_as(user)

      get(edit_issue_path(issue))

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "Edit Issue")
      expect(crumbs).to eq(
        [
          ["Home", home_path],
          ["Projects", projects_path],
          [issue.project.name, project_path(issue.project)],
          ["Fix it", issue_path(issue)]
        ]
      )
      expect(page).to have_css("form[action='#{issue_path(issue)}']")
      expect(page).to have_field("Title", with: "Fix it")
      expect(page).to have_button("Update Issue")
    end

    it "selects the current project among only my projects" do
      me = create(:user)
      current = create(:issues_project, user: me, name: "Beta")
      create(:issues_project, user: me, name: "Alpha")
      create(:issues_project, name: "Theirs")
      issue = create(:issue, user: me, project: current)
      login_as(me)

      get(edit_issue_path(issue))

      options = page.all("select[name='issue[project_id]'] option")
      expect(options.map(&:text)).to eq(["Alpha", "Beta"])
      expect(page).to have_select("Project", selected: "Beta")
      expect(page).not_to have_content("Theirs")
    end

    it "returns not found for another user's issue" do
      user = create(:user)
      issue = create(:issue)
      login_as(user)

      get(edit_issue_path(issue))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "update" do
    it "redirects a signed-out visitor and changes nothing" do
      issue = create(:issue, title: "Before")
      params = {issue: {title: "After"}}

      patch(issue_path(issue), params:)

      expect(response).to redirect_to(new_session_path)
      expect(issue.reload.title).to eq("Before")
    end

    it "updates my issue and leaves others alone" do
      user = create(:user)
      issue = create(:issue, user:, title: "Before", description: "Old")
      bystander = create(:issue, user:, title: "Bystander")
      login_as(user)
      params = {
        issue: {title: "After", description: "<strong>New</strong> text"}
      }

      patch(issue_path(issue), params:)

      issue.reload
      expect(response).to redirect_to(issue_path(issue))
      expect(flash[:notice]).to eq("Issue was successfully updated.")
      expect(issue.title).to eq("After")
      expect(issue.description.to_plain_text).to eq("New text")
      expect(bystander.reload.title).to eq("Bystander")
    end

    it "changes the status" do
      user = create(:user)
      issue = create(:issue, user:)
      login_as(user)
      params = {issue: {status: "done"}}

      patch(issue_path(issue), params:)

      expect(response).to redirect_to(issue_path(issue))
      expect(flash[:notice]).to eq("Issue was successfully updated.")
      expect(issue.reload.status).to eq("done")
    end

    it "keeps the status when the request omits it" do
      user = create(:user)
      issue = create(:issue, user:, title: "Before", status: :ready)
      login_as(user)
      params = {issue: {title: "After"}}

      patch(issue_path(issue), params:)

      issue.reload
      expect(response).to redirect_to(issue_path(issue))
      expect(issue.title).to eq("After")
      expect(issue.status).to eq("ready")
    end

    it "rejects a blank status and keeps the old one" do
      user = create(:user)
      issue = create(:issue, user:, status: :ready)
      login_as(user)
      params = {issue: {title: "Typed", status: ""}}

      patch(issue_path(issue), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is not included in the list")
      expect(page).to have_field("Title", with: "Typed")
      expect(issue.reload.status).to eq("ready")
    end

    it "moves my issue to another of my projects" do
      user = create(:user)
      issue = create(:issue, user:)
      target = create(:issues_project, user:)
      login_as(user)
      params = {issue: {project_id: target.id}}

      patch(issue_path(issue), params:)

      expect(response).to redirect_to(issue_path(issue))
      expect(flash[:notice]).to eq("Issue was successfully updated.")
      expect(issue.reload.project).to eq(target)
    end

    it "rejects a project of another user and keeps the project" do
      user = create(:user)
      issue = create(:issue, user:)
      original = issue.project
      theirs = create(:issues_project, name: "Theirs")
      login_as(user)
      params = {issue: {project_id: theirs.id}}

      patch(issue_path(issue), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("must exist")
      expect(page).to have_link(original.name, href: project_path(original))
      expect(page).not_to have_content("Theirs")
      expect(issue.reload.project).to eq(original)
    end

    it "rejects a project that does not exist and keeps the project" do
      user = create(:user)
      issue = create(:issue, user:)
      original = issue.project
      login_as(user)
      params = {issue: {project_id: 0}}

      patch(issue_path(issue), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("must exist")
      expect(page).to have_link(original.name, href: project_path(original))
      expect(issue.reload.project).to eq(original)
    end

    it "rejects a blank title and keeps the description" do
      user = create(:user)
      issue = create(:issue, user:, title: "Before")
      login_as(user)
      params = {issue: {title: "", description: "Keep this text"}}

      patch(issue_path(issue), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("can't be blank")
      expect(page).to have_css("h1", text: "Edit Issue")
      expect(page).to have_link("Before", href: issue_path(issue))
      expect(page).to have_css(
        "input[name='issue[description]'][value*='Keep this text']",
        visible: :all
      )
      expect(issue.reload.title).to eq("Before")
    end

    it "rejects a title over 255 characters and keeps it" do
      user = create(:user)
      issue = create(:issue, user:, title: "Before")
      login_as(user)
      title = "a" * 256
      params = {issue: {title:}}

      patch(issue_path(issue), params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is too long")
      expect(page).to have_field("Title", with: title)
      expect(page).to have_link("Before", href: issue_path(issue))
      expect(issue.reload.title).to eq("Before")
    end

    it "returns not found for another user's issue" do
      user = create(:user)
      issue = create(:issue, title: "Before")
      login_as(user)
      params = {issue: {title: "After"}}

      patch(issue_path(issue), params:)

      expect(response).to have_http_status(:not_found)
      expect(issue.reload.title).to eq("Before")
    end
  end

  describe "destroy" do
    it "redirects a signed-out visitor and deletes nothing" do
      issue = create(:issue)

      delete(issue_path(issue))

      expect(response).to redirect_to(new_session_path)
      expect(Issue.exists?(issue.id)).to be(true)
    end

    it "deletes my issue and leaves others alone" do
      user = create(:user)
      issue = create(:issue, user:)
      project = issue.project
      bystander = create(:issue, user:)
      login_as(user)

      delete(issue_path(issue))

      expect(response).to redirect_to(project_path(project))
      expect(response).to have_http_status(:see_other)
      expect(flash[:notice]).to eq("Issue was successfully deleted.")
      expect(Issue.exists?(issue.id)).to be(false)
      expect(Issue.exists?(bystander.id)).to be(true)
    end

    it "returns not found for another user's issue" do
      user = create(:user)
      issue = create(:issue)
      login_as(user)

      delete(issue_path(issue))

      expect(response).to have_http_status(:not_found)
      expect(Issue.exists?(issue.id)).to be(true)
    end
  end
end
