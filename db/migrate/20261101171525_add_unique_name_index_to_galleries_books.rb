class AddUniqueNameIndexToGalleriesBooks < ActiveRecord::Migration[8.1]
  def change
    add_index(
      :galleries_books,
      "gallery_id, lower(name)",
      unique: true,
      name: "index_galleries_books_on_gallery_id_and_lower_name"
    )
    remove_index(:galleries_books, :gallery_id)
  end
end
