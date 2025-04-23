class DropSimilarImages < ActiveRecord::Migration[8.0]
  def change
    drop_table(:galleries_image_similar_images)
  end
end
