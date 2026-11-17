# typed: strict

require "shellwords"

class StreamingVideoPreviewer < ActiveStorage::Previewer::VideoPreviewer
  # Rails loads this class before config/initializers/sorbet.rb adds
  # T::Sig to Module.
  extend T::Sig

  sig do
    params(
      options: T.untyped,
      block: T.proc.params(attachable: T::Hash[Symbol, T.untyped]).void
    ).void
  end
  def preview(**options, &block)
    draw(*T.unsafe(ffmpeg_arguments)) do |output|
      block.call({
        io: output,
        filename: "#{blob.filename.base}.jpg",
        content_type: "image/jpeg",
        **options
      })
    end
  end

  private

  sig { returns(T::Array[String]) }
  def ffmpeg_arguments
    [
      self.class.ffmpeg_path,
      *ActiveStorage.ffmpeg_format_whitelist_arguments,
      "-i",
      source,
      *Shellwords.split(ActiveStorage.video_preview_arguments),
      "-"
    ]
  end

  # ffmpeg reads an HTTP source with range requests, so it fetches only
  # the bytes near the frame it draws. Only DiskService defines
  # path_for, and Rails loads DiskService only when a configured service
  # uses it, so check the method instead of the class.
  sig { returns(String) }
  def source
    service = blob.service
    if service.respond_to?(:path_for)
      service.path_for(blob.key)
    else
      blob.url
    end
  end
end
