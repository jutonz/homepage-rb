class CreateRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_ingredients do |t|
      t.bigint :recipe_id, null: false
      t.bigint :ingredient_id, null: false
      t.decimal :quantity, precision: 8, scale: 2
      t.string :unit
      t.text :notes

      t.timestamps
    end

    add_index :recipe_ingredients, :recipe_id
    add_index :recipe_ingredients, :ingredient_id
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true
    add_foreign_key :recipe_ingredients, :recipes
    add_foreign_key :recipe_ingredients, :ingredients
  end
end
