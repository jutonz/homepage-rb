class CreateUserGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :user_groups do |t|
      t.string(:name, null: false)
      t.references(:owner, null: false, foreign_key: {to_table: :users})

      t.timestamps
    end
  end
end
