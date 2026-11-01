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
  end

  describe "new" do
    it "redirects a signed-out visitor to sign in" do
      get(new_issue_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the form" do
      user = create(:user)
      login_as(user)

      get(new_issue_path)

      expect(response).to be_successful
      expect(page).to have_css("h1", text: "New Issue")
      expect(page).to have_link("Home", href: home_path)
      expect(page).to have_link("Issues", href: issues_path)
      expect(page).to have_field("Title")
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
      login_as(user)
      params = {
        issue: {title: "Fix it", description: "<strong>Bold</strong> text"}
      }

      post(issues_path, params:)

      issue = Issue.last
      expect(response).to redirect_to(issue_path(issue))
      expect(flash[:notice]).to eq("Issue was successfully created.")
      expect(issue.user).to eq(user)
      expect(issue.title).to eq("Fix it")
      expect(issue.description.to_plain_text).to include("Bold text")
    end

    it "creates an issue with only a title" do
      user = create(:user)
      login_as(user)
      params = {issue: {title: "Fix it"}}

      post(issues_path, params:)

      issue = Issue.last
      expect(response).to redirect_to(issue_path(issue))
    end

    it "rejects a blank title and keeps the description" do
      user = create(:user)
      login_as(user)
      params = {issue: {title: "", description: "Keep this text"}}

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
      login_as(user)
      title = "a" * 256
      params = {issue: {title:}}

      post(issues_path, params:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(page).to have_content("is too long")
      expect(page).to have_field("Title", with: title)
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
  end
end
