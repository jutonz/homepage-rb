class CreatePlantsInboxImages < ActiveRecord::Migration[8.1]
  def change
    create_table(:plants_inbox_images) do |t|
      t.references(:user, null: false, foreign_key: true)
      t.datetime(:taken_at, null: false)

      t.timestamps
    end
  end
end
