class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes_recipes do |t|
      t.string :name, null: false
      t.text :description
      t.text :instructions
      t.bigint :user_id, null: false

      t.timestamps
    end

    add_index :recipes_recipes, :user_id
    add_foreign_key :recipes_recipes, :users
  end
end
