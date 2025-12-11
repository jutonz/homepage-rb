class CreateGalleriesBookImages < ActiveRecord::Migration[8.1]
  def change
    create_table :galleries_book_images do |t|
      t.references(
        :book,
        foreign_key: {to_table: :galleries_books},
        null: false
      )
      t.references(
        :image,
        foreign_key: {to_table: :galleries_images},
        null: false
      )
      t.integer(:order, null: false)
      t.timestamps
    end

    add_index(
      :galleries_book_images,
      [:book_id, :image_id],
      unique: true
    )
  end
end
