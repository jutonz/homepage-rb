require "rails_helper"

# == Schema Information
#
# Table name: issues
# Database name: primary
#
#  id         :bigint           not null, primary key
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

  it "has a valid factory" do
    issue = build(:issue)

    expect(issue).to be_valid
  end

  it "allows a blank description" do
    issue = build(:issue, description: "")

    expect(issue).to be_valid
  end
end
