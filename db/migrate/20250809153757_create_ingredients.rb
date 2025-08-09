class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes_ingredients do |t|
      t.string :name, null: false
      t.string :category
      t.bigint :user_id, null: false

      t.timestamps
    end

    add_index :recipes_ingredients, :user_id
    add_index :recipes_ingredients, [:user_id, :name], unique: true
    add_foreign_key :recipes_ingredients, :users
  end
end
