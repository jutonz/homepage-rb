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

  it "lists the six status labels in order with no blank option" do
    issue = build(:issue, user: nil)

    render_inline(described_class.new(issue:))

    options = page.all("select#issue_status option")
    expect(options.map(&:text)).to eq(
      ["Backlog", "Ready", "In Progress", "In Review", "Done", "Cancelled"]
    )
    expect(options.map { it[:value] }).to eq(
      %w[backlog ready in_progress in_review done cancelled]
    )
  end

  it "preselects Backlog for a new issue" do
    issue = build(:issue, user: nil)

    render_inline(described_class.new(issue:))

    expect(page).to have_select("Status", selected: "Backlog")
  end

  it "preselects the status of the issue" do
    issue = build(:issue, user: nil, status: :in_review)

    render_inline(described_class.new(issue:))

    expect(page).to have_select("Status", selected: "In Review")
  end

  it "preselects the saved status when the submitted status is unknown" do
    issue = build_stubbed(:issue, user: nil, status: :ready)
    issue.status = "bogus"

    render_inline(described_class.new(issue:))

    expect(page).to have_select("Status", selected: "Ready")
  end

  it "preselects the saved status when the submitted status is blank" do
    issue = build_stubbed(:issue, user: nil, status: :ready)
    issue.status = ""

    render_inline(described_class.new(issue:))

    expect(page).to have_select("Status", selected: "Ready")
  end

  it "keeps a valid status the user chose over the saved one" do
    issue = build_stubbed(:issue, user: nil, status: :ready)
    issue.status = :done

    render_inline(described_class.new(issue:))

    expect(page).to have_select("Status", selected: "Done")
  end
end
