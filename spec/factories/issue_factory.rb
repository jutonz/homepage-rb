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
FactoryBot.define do
  factory :issue do
    transient do
      project_key { nil }
    end

    user
    project do
      association(:issues_project, user:, **{key: project_key}.compact)
    end
    sequence(:title) { "Issue #{it}" }

    to_create do |issue|
      issue.save_with_number || raise(ActiveRecord::RecordInvalid, issue)
    end

    trait(:with_pr_url) { pr_url { "https://github.com/o/r/pull/1" } }
  end
end
