class RemoveUnitStringAndRequireUnitId < ActiveRecord::Migration[8.0]
  def change
    # Remove any recipe ingredients without a unit_id since units are now required
    execute "DELETE FROM recipes_recipe_ingredients WHERE unit_id IS NULL"

    remove_column :recipes_recipe_ingredients, :unit, :string
    change_column_null :recipes_recipe_ingredients, :unit_id, false
  end
end
