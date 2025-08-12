class CreateRecipeGroupUserGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_group_user_groups do |t|
      t.references(:recipe_group, null: false, foreign_key: true)
      t.references(:user_group, null: false, foreign_key: true)

      t.timestamps
    end

    add_index(
      :recipe_group_user_groups,
      [:recipe_group_id, :user_group_id],
      unique: true
    )
  end
end
