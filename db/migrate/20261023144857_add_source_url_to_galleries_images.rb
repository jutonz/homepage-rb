class AddSourceUrlToGalleriesImages < ActiveRecord::Migration[8.1]
  def change
    add_column(:galleries_images, :source_url, :string)
  end
end
