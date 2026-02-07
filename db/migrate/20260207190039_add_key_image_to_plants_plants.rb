class AddKeyImageToPlantsPlants < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :plants_plants,
      :key_image,
      foreign_key: {to_table: :plants_plant_images}
    )
  end
end
