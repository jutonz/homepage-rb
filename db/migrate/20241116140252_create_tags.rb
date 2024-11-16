class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :galleries_tags do |t|
      t.string(:name, null: false)
      t.references(:gallery, null: false, foreign_key: true)
      t.references(:user, null: false, foreign_key: true)

      t.timestamps
    end

    add_index(
      :galleries_tags,
      [:gallery_id, :name],
      unique: true
    )
  end
end
