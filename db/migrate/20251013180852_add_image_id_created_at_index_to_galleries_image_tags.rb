class AddImageIdCreatedAtIndexToGalleriesImageTags < ActiveRecord::Migration[8.0]
  def change
    add_index(
      :galleries_image_tags,
      [:image_id, :created_at],
      name: "index_galleries_image_tags_on_image_id_and_created_at"
    )
  end
end
