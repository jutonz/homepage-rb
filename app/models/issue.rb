# typed: strict

# == Schema Information
#
# Table name: issues
# Database name: primary
#
#  id         :bigint           not null, primary key
#  status     :enum             default("backlog"), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_issues_on_project_id  (project_id)
#  index_issues_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => issues_projects.id)
#  fk_rails_...  (user_id => users.id)
#
class Issue < ApplicationRecord
  belongs_to(:user)
  belongs_to(:project, class_name: "Issues::Project")
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
  validate(:project_belongs_to_user)

  private

  sig { void }
  def project_belongs_to_user
    issue_project = project
    return if issue_project.nil? || issue_project.user == user

    errors.add(:project, :required)
  end
end
