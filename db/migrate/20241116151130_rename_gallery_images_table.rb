class RenameGalleryImagesTable < ActiveRecord::Migration[7.2]
  def change
    rename_table(:gallery_images, :galleries_images)
  end
end
