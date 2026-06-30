class AddDownloadStartedAtToGalleriesRemoteVideoDownloads < ActiveRecord::Migration[8.1]
  def change
    add_column :galleries_remote_video_downloads, :download_started_at, :datetime
  end
end
