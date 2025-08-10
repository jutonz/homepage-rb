class AddFractionFieldsToRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes_recipe_ingredients, :numerator, :integer
    add_column :recipes_recipe_ingredients, :denominator, :integer
  end
end
