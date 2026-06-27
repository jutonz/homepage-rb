module Galleries
  class RemoteVideoDownloadJob < ApplicationJob
    queue_as :background

    POLL_INTERVAL = 30.seconds
    MAX_DURATION = 1.hour

    def perform(remote_video_download)
      @rvd = remote_video_download

      if rvd.status_pending?
        start_download
      elsif rvd.status_downloading?
        poll_download
      end
    end

    private

    attr_reader :rvd

    def start_download
      metube.add(url: rvd.url, prefix:)
      rvd.status_downloading!
      reenqueue
    end

    def poll_download
    end

    def reenqueue
      self.class.set(wait: POLL_INTERVAL).perform_later(rvd)
    end

    def prefix = "rvd-#{rvd.id}"

    def metube = @metube ||= Galleries::VideoDownloader::Metube.new
  end
end
