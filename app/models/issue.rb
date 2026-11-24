# typed: strict

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
  validates(:pr_url, http_url: true)
  normalizes(:pr_url, with: -> { it.strip.presence })
  validate(:project_belongs_to_user)

  sig { returns(String) }
  def identifier
    "#{T.must(project).key}-#{number}"
  end

  sig { returns(T::Boolean) }
  def save_with_number
    return false unless valid?

    if project_id_changed?
      self.number = T.must(project).take_next_issue_number
    end
    save!
  end

  private

  sig { void }
  def project_belongs_to_user
    issue_project = project
    return if issue_project.nil? || issue_project.user == user

    errors.add(:project, :required)
  end
end
