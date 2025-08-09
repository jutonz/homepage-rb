# == Schema Information
#
# Table name: recipes_recipe_ingredients
#
#  id            :bigint           not null, primary key
#  notes         :text
#  quantity      :decimal(8, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null
#  recipe_id     :bigint           not null
#  unit_id       :bigint           not null
#
# Indexes
#
#  idx_on_recipe_id_ingredient_id_b1a1ea5019          (recipe_id,ingredient_id) UNIQUE
#  index_recipes_recipe_ingredients_on_ingredient_id  (ingredient_id)
#  index_recipes_recipe_ingredients_on_recipe_id      (recipe_id)
#  index_recipes_recipe_ingredients_on_unit_id        (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => recipes_ingredients.id)
#  fk_rails_...  (recipe_id => recipes_recipes.id)
#  fk_rails_...  (unit_id => recipes_units.id)
#
module Recipes
  class RecipeIngredient < ApplicationRecord
    belongs_to :recipe, class_name: "Recipes::Recipe"
    belongs_to :ingredient, class_name: "Recipes::Ingredient"
    belongs_to :unit, class_name: "Recipes::Unit"

    validates :recipe_id,
      presence: true,
      uniqueness: {scope: :ingredient_id}
    validates :ingredient_id, presence: true
    validates :quantity,
      presence: true,
      numericality: {greater_than: 0}
  end
end
