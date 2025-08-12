# == Schema Information
#
# Table name: recipe_groups
#
#  id            :bigint           not null, primary key
#  description   :text
#  name          :string           not null
#  recipes_count :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  owner_id      :bigint           not null
#
# Indexes
#
#  index_recipe_groups_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class RecipeGroup < ActiveRecord::Base
  belongs_to(:owner, class_name: "User")
  has_many(:recipes, class_name: "Recipes::Recipe", dependent: :destroy)
  has_many(:recipe_group_user_groups, dependent: :destroy)
  has_many(:user_groups, through: :recipe_group_user_groups)

  validates(:name, presence: true)
end
