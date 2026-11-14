require "rails_helper"

# == Schema Information
#
# Table name: issues
# Database name: primary
#
#  id         :bigint           not null, primary key
#  status     :enum             default("Backlog"), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_issues_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Issue do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_rich_text(:description) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(255) }

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
    user = create(:user)

    Issue.connection.execute(
      "INSERT INTO issues (title, user_id, created_at, updated_at) " \
      "VALUES ('Old', #{user.id}, NOW(), NOW())"
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

  it "has a valid factory" do
    issue = build(:issue)

    expect(issue).to be_valid
  end

  it "allows a blank description" do
    issue = build(:issue, description: "")

    expect(issue).to be_valid
  end
end
