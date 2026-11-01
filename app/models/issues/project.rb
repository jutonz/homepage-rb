# typed: strict

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
module Issues
  class Project < ApplicationRecord
    belongs_to(:user)

    normalizes(:name, :key, with: ->(value) { value.strip })

    validates(
      :name,
      :key,
      presence: true,
      uniqueness: {scope: :user_id, case_sensitive: false}
    )
    validates(:name, length: {maximum: 255})
  end
end
