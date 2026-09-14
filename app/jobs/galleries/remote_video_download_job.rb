# typed: strict

module Galleries
  class RemoteVideoDownloadJob < ApplicationJob
    queue_as :background

    discard_on ActiveJob::DeserializationError

    POLL_INTERVAL = T.let(30.seconds, ActiveSupport::Duration)
    MAX_DURATION = T.let(1.hour, ActiveSupport::Duration)

    Entry = T.type_alias { Galleries::VideoDownloader::Metube::Entry }
    private_constant(:Entry)

    sig { params(remote_video_download: RemoteVideoDownload).void }
    def perform(remote_video_download)
      @rvd = T.let(remote_video_download, T.nilable(RemoteVideoDownload))

      if rvd.status_pending?
        start_download
      elsif rvd.status_downloading?
        poll_download
      end
    rescue => e
      fail!(e.message)
    end

    private

    sig { returns(RemoteVideoDownload) }
    def rvd = T.must(@rvd)

    sig { void }
    def start_download
      attach_or_add
      rvd.update!(
        status: :downloading,
        error_message: nil,
        download_started_at: Time.current
      )
      rvd.broadcast_row
      reenqueue
    end

    # Reattach to an in-progress (or already finished) MeTube download
    # instead of cancelling and restarting it. Only delete and re-add when
    # there is no entry, or MeTube reports the previous attempt errored.
    sig { void }
    def attach_or_add
      entry = existing_entry
      return if entry && entry["status"] != "error"

      cleanup_stale_entry
      metube.add(url: rvd.url, prefix:)
    end

    sig { returns(T.nilable(Entry)) }
    def existing_entry
      hist = metube.history
      hist.fetch("queue", []).find { matches_prefix?(it) } ||
        hist.fetch("done", []).find { matches_prefix?(it) }
    end

    sig { void }
    def poll_download
      entry = find_entry
      return handle_pending if entry.nil?

      case entry["status"]
      when "finished"
        handle_finished(entry)
      when "error"
        fail!(entry["error"] || entry["msg"])
      else
        handle_pending
      end
    end

    sig { void }
    def handle_pending
      if attempt_started_at + MAX_DURATION < Time.current
        fail!("timed out after #{MAX_DURATION.inspect}")
      else
        reenqueue
      end
    end

    # Measure the timeout from when the current attempt started polling, not
    # from creation, so retrying an old record gets a fresh window. Falls
    # back to created_at for records that predate download_started_at.
    sig { returns(ActiveSupport::TimeWithZone) }
    def attempt_started_at = rvd.download_started_at || rvd.created_at

    sig { returns(T.nilable(Entry)) }
    def find_entry
      metube.history.fetch("done", []).find { matches_prefix?(it) }
    end

    sig { params(entry: Entry).returns(T::Boolean) }
    def matches_prefix?(entry) = entry["custom_name_prefix"] == prefix

    sig { params(entry: Entry).void }
    def handle_finished(entry)
      filename = T.must(entry["filename"])
      bytes = metube.fetch_file(filename)
      gallery = T.must(rvd.gallery)
      image = T.let(nil, T.nilable(Galleries::Image))
      ActiveRecord::Base.transaction do
        image = gallery.images.create!(
          file: {
            io: StringIO.new(bytes),
            filename: File.basename(filename)
          }
        )
        image.add_tag(
          Galleries::Tag.tagging_needed(gallery),
          Galleries::Tag.video(gallery)
        )
        rvd.update!(status: :completed, image:)
      end
      rvd.broadcast_row
      Galleries::ImageProcessingJob.perform_later(T.must(image))
      cleanup(entry)
    end

    sig { params(entry: Entry).void }
    def cleanup(entry)
      # MeTube keys /delete on the entry url, not the id field.
      metube.delete(T.must(entry["url"]))
    rescue => e
      Rails.logger.warn(
        "RemoteVideoDownload #{rvd.id} cleanup failed: #{e.message}"
      )
    end

    sig { void }
    def reenqueue
      self.class.set(wait: POLL_INTERVAL).perform_later(rvd)
    end

    sig { void }
    def cleanup_stale_entry
      metube.delete_by_prefix(prefix)
    rescue => e
      Rails.logger.warn(
        "RemoteVideoDownload #{rvd.id} stale cleanup failed: #{e.message}"
      )
    end

    sig { params(message: T.nilable(String)).void }
    def fail!(message)
      rvd.update!(status: :failed, error_message: message)
      rvd.broadcast_row
    end

    sig { returns(String) }
    def prefix = rvd.metube_prefix

    sig { returns(Galleries::VideoDownloader::Metube) }
    def metube
      @metube ||= T.let(
        Galleries::VideoDownloader::Metube.new,
        T.nilable(Galleries::VideoDownloader::Metube)
      )
    end
  end
end
