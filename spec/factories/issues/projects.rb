# == Schema Information
#
# Table name: issues_projects
# Database name: primary
#
#  id         :bigint           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_issues_projects_on_user_id_and_lower_key   (user_id, lower((key)::text)) UNIQUE
#  index_issues_projects_on_user_id_and_lower_name  (user_id, lower((name)::text)) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :issues_project, class: "Issues::Project" do
    user
    sequence(:name) { "Project #{it}" }
    sequence(:key) { "P#{it}" }
  end
end
