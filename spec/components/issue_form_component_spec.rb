require "rails_helper"

RSpec.describe IssueFormComponent, type: :component do
  it "renders the title field, description editor, and submit button" do
    issue = build(:issue, user: nil)
    component = described_class.new(issue:)

    render_inline(component)

    expect(page).to have_css("form[action='#{issues_path}']")
    expect(page).to have_field("Title")
    expect(page).to have_css("input#issue_title[autofocus]")
    expect(page).to have_css("label", text: "Description")
    expect(page).to have_css("input[name='issue[description]']", visible: :all)
    expect(page).to have_button("Create Issue")
  end

  it "fills the title and description from the issue" do
    issue = build(
      :issue,
      user: nil,
      title: "Broken thing",
      description: "<strong>Bold</strong> text"
    )
    component = described_class.new(issue:)

    render_inline(component)

    expect(page).to have_field("Title", with: "Broken thing")
    expect(page).to have_css(
      "input[name='issue[description]'][value*='Bold']",
      visible: :all
    )
  end

  it "shows validation errors" do
    issue = build(:issue, user: nil, title: "")
    issue.validate
    component = described_class.new(issue:)

    render_inline(component)

    expect(page).to have_content("can't be blank")
  end
end
