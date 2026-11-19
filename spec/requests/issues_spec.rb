require "rails_helper"

RSpec.describe IssuesController do
  def row_titles
    page.all("[data-role=issue]").map(&:text)
  end

  describe "index" do
    it "redirects a signed-out visitor to sign in" do
      get(issues_path)

      expect(response).to redirect_to(new_session_path)
      expect(session[:return_to]).to eql(issues_path)
    end

    it "lists only my issues" do
      me, them = create_pair(:user)
      mine = create(:issue, user: me)
      theirs = create(:issue, user: them)
      login_as(me)

      get(issues_path)

      expect(page).to have_css("[data-role=issue]", text: mine.title)
      expect(page).not_to have_content(theirs.title)
      expect(page).not_to have_content("No issues yet")
    end

    it "lists the newest issue first" do
      user = create(:user)
      old = create(:issue, user:, created_at: 2.days.ago)
      newer = create(:issue, user:, created_at: 1.day.ago)
      login_as(user)

      get(issues_path)

      expect(row_titles).to eq([newer.title, old.title])
    end

    it "paginates issues" do
      user = create(:user)
      old = create(:issue, user:, created_at: 2.days.ago)
      newer = create(:issue, user:, created_at: 1.day.ago)
      login_as(user)
      stub_const("IssuesController::PER_PAGE", 1)

      get(issues_path)
      first_page = row_titles
      get(issues_path(page: 2))
      second_page = row_titles

      expect(first_page).to eq([newer.title])
      expect(second_page).to eq([old.title])
      expect(page).to have_link("1", href: issues_path)
    end

    it "shows an empty state with a link to add an issue" do
      user = create(:user)
      login_as(user)

      get(issues_path)

      expect(page).to have_content("No issues yet")
      expect(page).to have_link("New Issue", href: new_issue_path)
      expect(page).to have_link("Home", href: home_path)
    end

    it "links to my projects" do
      user = create(:user)
      login_as(user)

      get(issues_path)

      expect(page).to have_link("Projects", href: projects_path)
    end

    it "does not show a status on a row" do
      user = create(:user)
      issue = create(:issue, user:)
      login_as(user)

      get(issues_path)

      expect(page).to have_css("[data-role=issue]", text: issue.title)
      expect(page).not_to have_content("Backlog")
      expect(page).not_to have_css("span.rounded-full")
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
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Issues", href: issues_path)
      expect(page).to have_field("Title")
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

    it "stores a pull request URL" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      url = "https://github.com/o/r/pull/1"
      params = {issue: {title: "Fix it", pr_url: url, project_id: project.id}}

      post(issues_path, params:)

      issue = Issue.last
      expect(response).to redirect_to(issue_path(issue))
      expect(issue.pr_url).to eq(url)
    end

    it "stores a blank pull request URL as nil" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      params = {issue: {title: "Fix it", pr_url: "  ", project_id: project.id}}

      post(issues_path, params:)

      issue = Issue.last
      expect(response).to redirect_to(issue_path(issue))
      expect(issue.pr_url).to be_nil
    end

    it "rejects an invalid pull request URL and creates nothing" do
      user = create(:user)
      project = create(:issues_project, user:)
      login_as(user)
      params = {
        issue: {
          title: "Fix it",
          pr_url: "ftp://example.com/x",
          project_id: project.id
        }
      }

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is not a valid http(s) URL")
      expect(page).to have_field("Title", with: "Fix it")
      expect(Issue.count).to eq(0)
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
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Issues", href: issues_path)
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

    it "links to the pull request beside the status pill" do
      user = create(:user)
      issue = create(:issue, :with_pr_url, user:)
      login_as(user)

      get(issue_path(issue))

      expect(page).to have_css(
        "div.mb-4 a[href='#{issue.pr_url}'][target='_blank']" \
        "[rel='noopener noreferrer']",
        text: "Pull request"
      )
    end

    it "shows no pull request link when there is none" do
      user = create(:user)
      issue = create(:issue, user:)
      login_as(user)

      get(issue_path(issue))

      expect(page).to have_css("div.mb-4 span", text: "Backlog")
      expect(page).not_to have_link("Pull request")
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
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Issues", href: issues_path)
      expect(page).to have_link("Fix it", href: issue_path(issue))
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

    it "stores a pull request URL" do
      user = create(:user)
      issue = create(:issue, user:)
      login_as(user)
      url = "https://github.com/o/r/pull/2"
      params = {issue: {pr_url: url}}

      patch(issue_path(issue), params:)

      expect(response).to redirect_to(issue_path(issue))
      expect(issue.reload.pr_url).to eq(url)
    end

    it "clears the pull request URL when the field is empty" do
      user = create(:user)
      issue = create(:issue, :with_pr_url, user:)
      login_as(user)
      params = {issue: {pr_url: ""}}

      patch(issue_path(issue), params:)

      expect(response).to redirect_to(issue_path(issue))
      expect(issue.reload.pr_url).to be_nil
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
      bystander = create(:issue, user:)
      login_as(user)

      delete(issue_path(issue))

      expect(response).to redirect_to(issues_path)
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
