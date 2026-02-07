class RequireTakenAtForPlantsPlantImages < ActiveRecord::Migration[8.1]
  def up
    Plants::PlantImage.where(taken_at: nil)
      .update_all(taken_at: Time.current)

    change_column_null(:plants_plant_images, :taken_at, false)
  end

  def down
    change_column_null(:plants_plant_images, :taken_at, true)
  end
end
