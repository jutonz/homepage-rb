# == Schema Information
#
# Table name: galleries_remote_video_downloads
# Database name: primary
#
#  id            :bigint           not null, primary key
#  error_message :text
#  status        :enum             default("pending"), not null
#  url           :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  gallery_id    :bigint           not null
#  image_id      :bigint
#
# Indexes
#
#  index_galleries_remote_video_downloads_on_gallery_id  (gallery_id)
#  index_galleries_remote_video_downloads_on_image_id    (image_id)
#  index_galleries_rvd_on_gallery_id_and_url             (gallery_id,url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#  fk_rails_...  (image_id => galleries_images.id) ON DELETE => nullify
#
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

    validates :url,
      presence: true,
      uniqueness: {scope: :gallery_id}

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
