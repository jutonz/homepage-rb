class CreatePlantsPlantImages < ActiveRecord::Migration[8.1]
  def change
    create_table(:plants_plant_images) do |t|
      t.references(
        :plant,
        null: false,
        foreign_key: {to_table: :plants_plants}
      )
      t.datetime(:taken_at)

      t.timestamps
    end
  end
end
