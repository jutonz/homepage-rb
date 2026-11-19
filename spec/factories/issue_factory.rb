# == Schema Information
#
# Table name: issues
# Database name: primary
#
#  id         :bigint           not null, primary key
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
#  index_issues_on_project_id  (project_id)
#  index_issues_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => issues_projects.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :issue do
    user
    project { association(:issues_project, user:) }
    sequence(:title) { "Issue #{it}" }

    trait(:with_pr_url) { pr_url { "https://github.com/o/r/pull/1" } }
  end
end
