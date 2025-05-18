class AddPerceptualHashToImages < ActiveRecord::Migration[8.0]
  def change
    add_column(
      :galleries_images,
      :perceptual_hash,
      :vector,
      limit: 64
    )
  end
end
