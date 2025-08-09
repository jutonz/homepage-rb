class RenameRecipeIngredientsToRecipesRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    rename_table :recipe_ingredients, :recipes_recipe_ingredients
  end
end
