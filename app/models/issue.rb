# typed: strict

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
class Issue < ApplicationRecord
  belongs_to(:user)
  has_rich_text(:description)

  enum(
    :status,
    {
      backlog: "Backlog",
      ready: "Ready",
      in_progress: "In Progress",
      in_review: "In Review",
      done: "Done",
      cancelled: "Cancelled"
    },
    validate: true,
    prefix: true
  )

  validates(:title, presence: true, length: {maximum: 255})
end
