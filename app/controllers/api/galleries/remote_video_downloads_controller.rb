module Api
  module Galleries
    class RemoteVideoDownloadsController < BaseController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @gallery = find_gallery
        @remote_video_download = authorize(
          @gallery.remote_video_downloads.build(
            remote_video_download_params
          )
        )

        if @remote_video_download.save
          ::Galleries::RemoteVideoDownloadJob.perform_later(
            @remote_video_download
          )
          head :accepted
        else
          render json: {
            errors: @remote_video_download.errors.full_messages
          }, status: :bad_request
        end
      end

      private

      def find_gallery
        policy_scope(Gallery).find(params[:gallery_id])
      end

      def remote_video_download_params
        params
          .require(:remote_video_download)
          .permit(:url)
      end
    end
  end
end
