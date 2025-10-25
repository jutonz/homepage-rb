# == Schema Information
#
# Table name: recipes_recipe_ingredients
# Database name: primary
#
#  id            :bigint           not null, primary key
#  denominator   :integer
#  notes         :text
#  numerator     :integer
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
FactoryBot.define do
  factory :recipes_recipe_ingredient, class: "Recipes::RecipeIngredient" do
    recipe factory: :recipes_recipe
    ingredient factory: :recipes_ingredient
    unit factory: :recipes_unit
    quantity { 2.5 }
    notes { "All-purpose flour works best" }
  end
end
