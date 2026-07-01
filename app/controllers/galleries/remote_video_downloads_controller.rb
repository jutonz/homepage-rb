module Galleries
  class RemoteVideoDownloadsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      @gallery = find_gallery
      authorize(@gallery.remote_video_downloads.new, :index?)
      @remote_video_downloads =
        @gallery.remote_video_downloads
          .includes(image: [:gallery, {file_attachment: :blob}])
          .order(created_at: :desc)
    end

    def new
      @gallery = find_gallery
      @remote_video_download = authorize(
        @gallery.remote_video_downloads.new
      )
    end

    def edit
      @gallery = find_gallery
      @remote_video_download = authorize(
        @gallery.remote_video_downloads.find(params[:id])
      )
    end

    def create
      @gallery = find_gallery
      @remote_video_download = authorize(
        @gallery.remote_video_downloads.build(
          remote_video_download_params
        )
      )

      if @remote_video_download.save
        Galleries::RemoteVideoDownloadJob.perform_later(
          @remote_video_download
        )
        redirect_to(
          gallery_remote_video_downloads_path(@gallery),
          notice: "Video download queued"
        )
      else
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      @gallery = find_gallery
      @remote_video_download = authorize(
        @gallery.remote_video_downloads.find(params[:id])
      )

      @remote_video_download.destroy!
      cancel_metube_entry(@remote_video_download)

      redirect_to(
        gallery_remote_video_downloads_path(@gallery),
        status: :see_other,
        notice: "Video download was deleted."
      )
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end

    def cancel_metube_entry(remote_video_download)
      Galleries::VideoDownloader::Metube.new
        .delete_by_prefix(remote_video_download.metube_prefix)
    rescue => e
      Rails.logger.warn(
        "RemoteVideoDownload #{remote_video_download.id} " \
        "metube cleanup failed: #{e.message}"
      )
    end

    def remote_video_download_params
      params
        .require(:remote_video_download)
        .permit(:url)
    end
  end
end
