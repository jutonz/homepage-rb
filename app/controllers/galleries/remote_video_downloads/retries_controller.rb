module Galleries
  module RemoteVideoDownloads
    class RetriesController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @gallery = policy_scope(Gallery).find(params[:gallery_id])
        @remote_video_download = authorize(
          @gallery.remote_video_downloads.find(
            params[:remote_video_download_id]
          ),
          :update?
        )

        @remote_video_download.update!(
          status: :pending,
          error_message: nil
        )
        @remote_video_download.broadcast_row
        Galleries::RemoteVideoDownloadJob.perform_later(
          @remote_video_download
        )

        redirect_to(
          gallery_remote_video_downloads_path(@gallery),
          notice: "Retry queued"
        )
      end
    end
  end
end
