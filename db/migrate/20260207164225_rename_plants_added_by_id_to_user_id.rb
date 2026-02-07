class RenamePlantsAddedByIdToUserId < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key(
      :plants_plants,
      column: :added_by_id,
      to_table: :users
    )
    rename_column(:plants_plants, :added_by_id, :user_id)
    add_foreign_key(:plants_plants, :users, column: :user_id)
  end
end
