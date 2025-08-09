class RenameIngredientsToRecipesIngredients < ActiveRecord::Migration[8.0]
  def change
    rename_table :ingredients, :recipes_ingredients
  end
end
