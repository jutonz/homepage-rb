Rails.application.config.active_storage.tap do |config|
  config.previewers = config.previewers.map do |previewer|
    if previewer == ActiveStorage::Previewer::VideoPreviewer
      StreamingVideoPreviewer
    else
      previewer
    end
  end

  # VideoAnalyzer downloads the whole video to run ffprobe, and nothing
  # reads the metadata it records.
  config.analyzers -= [ActiveStorage::Analyzer::VideoAnalyzer]
end
