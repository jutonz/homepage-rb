class RenameRecipesToRecipesRecipes < ActiveRecord::Migration[8.0]
  def change
    rename_table :recipes, :recipes_recipes
  end
end
