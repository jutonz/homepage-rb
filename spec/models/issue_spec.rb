require "rails_helper"

# == Schema Information
#
# Table name: issues
# Database name: primary
#
#  id         :bigint           not null, primary key
#  number     :integer          not null
#  pr_url     :string
#  status     :enum             default("backlog"), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_issues_on_project_id             (project_id)
#  index_issues_on_project_id_and_number  (project_id,number) UNIQUE
#  index_issues_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => issues_projects.id)
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Issue do
  it { is_expected.to belong_to(:user) }

  it do
    is_expected.to belong_to(:project).class_name("Issues::Project")
  end

  it { is_expected.to have_rich_text(:description) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(255) }

  it do
    is_expected.to allow_value("http://github.com/o/r/pull/1").for(:pr_url)
  end

  it do
    is_expected.to allow_value("https://github.com/o/r/pull/1").for(:pr_url)
  end

  it do
    is_expected.not_to allow_value("github.com/o/r/pull/1").for(:pr_url)
  end

  it { is_expected.not_to allow_value("ftp://example.com/x").for(:pr_url) }
  it { is_expected.not_to allow_value("https://a b.com").for(:pr_url) }
  it { is_expected.not_to allow_value("https://").for(:pr_url) }
  it { is_expected.to normalize(:pr_url).from("   ").to(nil) }

  it do
    is_expected.to normalize(:pr_url)
      .from(" https://github.com/o/r/pull/1 \n")
      .to("https://github.com/o/r/pull/1")
  end

  it {
    is_expected.to define_enum_for(:status)
      .with_values(
        backlog: "Backlog",
        ready: "Ready",
        in_progress: "In Progress",
        in_review: "In Review",
        done: "Done",
        cancelled: "Cancelled"
      )
      .backed_by_column_of_type(:enum)
      .with_prefix(:status)
      .validating
  }

  it "starts a new issue in Backlog" do
    issue = build(:issue)

    expect(issue.status).to eq("backlog")
    expect(issue).to be_status_backlog
  end

  it "casts a label to its key" do
    issue = build(:issue, status: "In Progress")

    expect(issue.status).to eq("in_progress")
  end

  it "stores exactly the six labels in order in the database enum" do
    labels = Issue.connection.select_values(
      "SELECT unnest(enum_range(NULL::issue_status))::text"
    )

    expect(labels).to eq(Issue.statuses.values)
  end

  it "fills the status of a row inserted without one" do
    project = create(:issues_project)

    Issue.connection.execute(
      "INSERT INTO issues " \
      "(title, user_id, project_id, number, created_at, updated_at) " \
      "VALUES ('Old', #{project.user_id}, #{project.id}, 1, NOW(), NOW())"
    )

    expect(Issue.find_by!(title: "Old").status).to eq("backlog")
  end

  it "refuses a status outside the list in the database" do
    issue = create(:issue)

    expect {
      Issue.transaction(requires_new: true) do
        Issue.where(id: issue.id).update_all("status = 'bogus'")
      end
    }.to raise_error(ActiveRecord::StatementInvalid, /invalid input value/)
    expect(issue.reload.status).to eq("backlog")
  end

  it "refuses a nil status in the database" do
    issue = create(:issue)

    expect {
      Issue.transaction(requires_new: true) do
        Issue.where(id: issue.id).update_all(status: nil)
      end
    }.to raise_error(ActiveRecord::NotNullViolation)
    expect(issue.reload.status).to eq("backlog")
  end

  it do
    is_expected.to have_db_column(:number)
      .of_type(:integer)
      .with_options(null: false)
  end

  it { is_expected.to have_db_index(%i[project_id number]).unique }

  it "refuses a second issue with the same number in a project" do
    first = create(:issue)
    duplicate = build(
      :issue,
      user: first.user,
      project: first.project,
      number: first.number
    )

    expect { duplicate.save!(validate: false) }
      .to raise_error(ActiveRecord::RecordNotUnique, /project_id_and_number/)
  end

  it "allows the same number in another project" do
    first = create(:issue)
    other = build(:issue, number: first.number)

    expect { other.save!(validate: false) }.not_to raise_error
    expect(other.reload.number).to eq(first.number)
  end

  describe "#identifier" do
    it "keeps case and inner characters of the key" do
      project = build_stubbed(:issues_project, key: "In-fra x")
      issue = build_stubbed(:issue, project:, number: 12)

      expect(issue.identifier).to eq("In-fra x-12")
    end

    it "follows a key change and keeps the number" do
      issue = create(:issue)
      issue.project.update!(key: "OPS")

      expect(issue.identifier).to eq("OPS-#{issue.number}")
    end
  end

  describe "#save_with_number" do
    it "never reuses the number of a deleted issue" do
      user = create(:user)
      project = create(:issues_project, user:)
      create(:issue, user:, project:)
      newest = create(:issue, user:, project:)
      newest.destroy!

      issue = create(:issue, user:, project:)

      expect(issue.number).to eq(3)
      expect(project.reload.last_issue_number).to eq(3)
    end

    it "takes no number and returns false for an invalid new issue" do
      project = create(:issues_project)
      issue = build(:issue, user: project.user, project:, title: "")

      result = issue.save_with_number

      expect(result).to be(false)
      expect(issue.errors[:title]).to eq(["can't be blank"])
      expect(issue.number).to be_nil
      expect(project.reload.last_issue_number).to eq(0)
    end

    it "keeps the number when the project does not change" do
      issue = create(:issue)
      issue.title = "Renamed"

      result = issue.save_with_number

      expect(result).to be(true)
      expect(issue.reload.title).to eq("Renamed")
      expect(issue.number).to eq(1)
      expect(issue.project.reload.last_issue_number).to eq(1)
    end

    it "gives a new number when the issue moves back" do
      user = create(:user)
      source = create(:issues_project, user:)
      target = create(:issues_project, user:)
      issue = create(:issue, user:, project: source)
      issue.project = target
      issue.save_with_number
      issue.project = source

      issue.save_with_number

      expect(issue.reload.project).to eq(source)
      expect(issue.number).to eq(2)
      expect(source.reload.last_issue_number).to eq(2)
    end

    it "keeps the identifier and counters when a move is refused" do
      user = create(:user)
      issue = create(:issue, user:)
      source = issue.project
      theirs = create(:issues_project)
      issue.project = theirs

      result = issue.save_with_number

      expect(result).to be(false)
      expect(issue.errors[:project]).to eq(["must exist"])
      expect(issue.reload.number).to eq(1)
      expect(issue.identifier).to eq("#{source.key}-1")
      expect(source.reload.last_issue_number).to eq(1)
      expect(theirs.reload.last_issue_number).to eq(0)
    end
  end

  it "has a valid factory" do
    issue = build(:issue)

    expect(issue).to be_valid
  end

  it "requires a project" do
    issue = build(:issue, project: nil)

    expect(issue).not_to be_valid
    expect(issue.errors.full_messages).to eq(["Project must exist"])
  end

  it "rejects a project of a different user" do
    project = build(:issues_project)
    issue = build(:issue, project:)

    expect(issue).not_to be_valid
    expect(issue.errors.full_messages).to eq(["Project must exist"])
  end

  it "allows a blank description" do
    issue = build(:issue, description: "")

    expect(issue).to be_valid
  end
end
