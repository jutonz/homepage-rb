class RemoveInstructionsFromRecipes < ActiveRecord::Migration[8.0]
  def change
    remove_column :recipes_recipes, :instructions, :text
  end
end
