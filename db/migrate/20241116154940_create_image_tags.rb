class CreateImageTags < ActiveRecord::Migration[7.2]
  def change
    create_table :galleries_image_tags do |t|
      t.references(
        :image,
        foreign_key: {to_table: :galleries_images},
        null: false
      )
      t.references(
        :tag,
        foreign_key: {to_table: :galleries_tags},
        null: false
      )
      t.timestamps
    end

    add_index(
      :galleries_image_tags,
      [:tag_id, :image_id],
      unique: true
    )
  end
end
