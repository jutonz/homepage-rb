class DeleteExistingRecipesAndAddRecipeGroupId < ActiveRecord::Migration[8.0]
  def up
    # Delete all existing recipes as specified in the requirements
    execute("DELETE FROM recipes_recipe_ingredients")
    execute("DELETE FROM recipes_recipes")

    # Add recipe_group_id to recipes table
    add_reference(
      :recipes_recipes,
      :recipe_group,
      null: false,
      foreign_key: true
    )
  end

  def down
    remove_reference(:recipes_recipes, :recipe_group, foreign_key: true)
  end
end
