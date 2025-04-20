class CreateSimilarImages < ActiveRecord::Migration[8.0]
  def change
    create_table :galleries_image_similar_images do |t|
      t.references(
        :parent_image,
        foreign_key: {to_table: :galleries_images},
        null: false
      )
      t.references(
        :image,
        foreign_key: {to_table: :galleries_images},
        null: false
      )
      t.integer(:position, null: false)
      t.timestamps
    end

    add_index(
      :galleries_image_similar_images,
      [:parent_image_id, :position],
      unique: true
    )
  end
end
