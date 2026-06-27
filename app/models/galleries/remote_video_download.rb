module Galleries
  class RemoteVideoDownload < ApplicationRecord
    belongs_to :gallery
    belongs_to :image,
      class_name: "Galleries::Image",
      optional: true

    enum :status,
      {
        pending: "pending",
        downloading: "downloading",
        completed: "completed",
        failed: "failed"
      },
      validate: true,
      prefix: true

    validates :url, presence: true

    def broadcast_row
      Turbo::StreamsChannel.broadcast_replace_to(
        gallery.remote_video_downloads_stream_name,
        target: "remote_video_download_#{id}",
        partial: "galleries/remote_video_downloads/row",
        locals: {remote_video_download: self}
      )
    rescue => e
      Rails.logger.warn(
        "RemoteVideoDownload #{id} broadcast failed: #{e.message}"
      )
    end
  end
end
