class AddUnitToRecipesRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    add_reference :recipes_recipe_ingredients, :unit,
      null: true,
      foreign_key: {to_table: :recipes_units}
  end
end
