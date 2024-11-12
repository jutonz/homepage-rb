class CreateGalleries < ActiveRecord::Migration[7.2]
  def change
    create_table :galleries do |t|
      t.references(:user, null: false, foreign_key: true)
      t.string(:name, null: false, index: {unique: true})
      t.timestamps
    end

    create_table :gallery_images do |t|
      t.references(:gallery, null: false, foreign_key: true)
      t.timestamps
    end
  end
end
