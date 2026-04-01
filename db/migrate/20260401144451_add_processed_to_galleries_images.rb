class AddProcessedToGalleriesImages < ActiveRecord::Migration[8.1]
  def change
    add_column(
      :galleries_images,
      :processed_at,
      :datetime
    )
  end
end
