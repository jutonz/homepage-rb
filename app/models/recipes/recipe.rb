# == Schema Information
#
# Table name: recipes_recipes
#
#  id              :bigint           not null, primary key
#  description     :text
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  recipe_group_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_recipes_recipes_on_recipe_group_id  (recipe_group_id)
#  index_recipes_recipes_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_group_id => recipe_groups.id)
#  fk_rails_...  (user_id => users.id)
#
module Recipes
  class Recipe < ApplicationRecord
    belongs_to :user
    belongs_to :recipe_group
    has_many :recipe_ingredients,
      class_name: "Recipes::RecipeIngredient",
      dependent: :destroy
    has_many :ingredients,
      through: :recipe_ingredients,
      class_name: "Recipes::Ingredient"

    has_rich_text :instructions

    validates :name, presence: true
  end
end
