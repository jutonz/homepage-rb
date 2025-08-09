class CreateRecipesUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes_units do |t|
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.string :unit_type, null: false

      t.timestamps
    end

    add_index :recipes_units, :name, unique: true
    add_index :recipes_units, :abbreviation, unique: true
    add_index :recipes_units, :unit_type
  end
end
