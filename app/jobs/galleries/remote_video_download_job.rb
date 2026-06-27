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
    rescue Faraday::Error => e
      rvd.update!(status: :failed, error_message: e.message)
    end

    private

    attr_reader :rvd

    def start_download
      metube.add(url: rvd.url, prefix:)
      rvd.status_downloading!
      reenqueue
    end

    def poll_download
      entry = find_entry
      return handle_pending if entry.nil?

      case entry["status"]
      when "finished"
        handle_finished(entry)
      when "error"
        rvd.update!(
          status: :failed,
          error_message: entry["error"] || entry["msg"]
        )
      else
        handle_pending
      end
    end

    def handle_pending
      if rvd.created_at + MAX_DURATION < Time.current
        rvd.update!(
          status: :failed,
          error_message: "timed out after #{MAX_DURATION.inspect}"
        )
      else
        reenqueue
      end
    end

    def find_entry
      metube.history.fetch("done", [])
        .find { it["custom_name_prefix"] == prefix }
    end

    def handle_finished(entry)
      bytes = metube.fetch_file(entry["filename"])
      image = rvd.gallery.images.create!(
        file: {
          io: StringIO.new(bytes),
          filename: File.basename(entry["filename"])
        }
      )
      image.add_tag(Galleries::Tag.tagging_needed(rvd.gallery))
      Galleries::ImageProcessingJob.perform_later(image)
      rvd.update!(status: :completed, image:)
      cleanup(entry)
    end

    def cleanup(entry)
      metube.delete(entry["id"])
    rescue => e
      Rails.logger.warn(
        "RemoteVideoDownload #{rvd.id} cleanup failed: #{e.message}"
      )
    end

    def reenqueue
      self.class.set(wait: POLL_INTERVAL).perform_later(rvd)
    end

    def prefix = "rvd-#{rvd.id}"

    def metube = @metube ||= Galleries::VideoDownloader::Metube.new
  end
end
