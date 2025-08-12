class AddRecipesCountToRecipeGroups < ActiveRecord::Migration[8.0]
  def up
    add_column :recipe_groups, :recipes_count, :integer, default: 0, null: false

    # Populate counter cache for existing records
    RecipeGroup.find_each do |recipe_group|
      RecipeGroup.reset_counters(recipe_group.id, :recipes)
    end
  end

  def down
    remove_column :recipe_groups, :recipes_count
  end
end
