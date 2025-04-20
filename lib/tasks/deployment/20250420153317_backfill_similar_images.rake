namespace :after_party do
  desc "Deployment task: backfill_similar_images"
  task backfill_similar_images: :environment do
    puts "Running deploy task 'backfill_similar_images'"

    Galleries::Image
      .joins(:tags)
      .find_each { Galleries::UpdateSimilarImagesJob.perform_later(it) }

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
