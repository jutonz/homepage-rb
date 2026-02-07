class CreatePlantsPlants < ActiveRecord::Migration[8.1]
  def change
    create_table :plants_plants do |t|
      t.string :name, null: false
      t.datetime :purchased_at
      t.string :purchased_from
      t.references :added_by, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
