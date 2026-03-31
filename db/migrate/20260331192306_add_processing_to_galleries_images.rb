class AddProcessingToGalleriesImages < ActiveRecord::Migration[8.1]
  def change
    add_column :galleries_images, :processing, :boolean,
      null: false, default: false
  end
end
