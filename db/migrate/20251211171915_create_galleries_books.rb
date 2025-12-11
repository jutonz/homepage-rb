class CreateGalleriesBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :galleries_books do |t|
      t.references(:gallery, null: false, foreign_key: true)
      t.string(:name, null: false)
      t.timestamps
    end
  end
end
