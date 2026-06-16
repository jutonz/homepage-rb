class AddDiedAtToPlantsPlants < ActiveRecord::Migration[8.1]
  def change
    add_column(:plants_plants, :died_at, :datetime)
  end
end
