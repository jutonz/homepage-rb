namespace :after_party do
  desc "Deployment task: backfill_video_posters"
  task backfill_video_posters: :environment do
    puts "Running deploy task 'backfill_video_posters'"

    Galleries::Image
      .joins(file_attachment: :blob)
      .where("active_storage_blobs.content_type LIKE ?", "video/%")
      .in_batches do |batch|
        batch
          .map { Galleries::ImageProcessingJob.new(it) }
          .then { ActiveJob.perform_all_later(it) }
      end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
