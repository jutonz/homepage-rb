module Galleries
  class RemoteVideoDownloadsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def new
      @gallery = find_gallery
      @remote_video_download = authorize(
        @gallery.remote_video_downloads.new
      )
    end

    private

    def find_gallery
      policy_scope(Gallery).find(params[:gallery_id])
    end
  end
end
