class AddUniqueIndexToGalleriesRemoteVideoDownloads <
  ActiveRecord::Migration[8.1]
  def change
    add_index(
      :galleries_remote_video_downloads,
      [:gallery_id, :url],
      unique: true,
      name: "index_galleries_rvd_on_gallery_id_and_url"
    )
  end
end
