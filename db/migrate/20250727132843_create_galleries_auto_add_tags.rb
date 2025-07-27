class CreateGalleriesAutoAddTags < ActiveRecord::Migration[8.0]
  def change
    create_table :galleries_auto_add_tags do |t|
      t.references :tag, null: false, foreign_key: {to_table: :galleries_tags}
      t.references :auto_add_tag, null: false, foreign_key: {to_table: :galleries_tags}

      t.timestamps
    end

    add_index :galleries_auto_add_tags, [:tag_id, :auto_add_tag_id], unique: true
  end
end
