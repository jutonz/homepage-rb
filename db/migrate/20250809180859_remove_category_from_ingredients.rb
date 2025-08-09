class RemoveCategoryFromIngredients < ActiveRecord::Migration[8.0]
  def change
    remove_column :recipes_ingredients, :category, :string
  end
end
