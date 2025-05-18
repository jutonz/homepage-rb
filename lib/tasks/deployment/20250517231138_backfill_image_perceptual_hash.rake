namespace :after_party do
  desc "Deployment task: backfill_image_perceptual_hash"
  task backfill_image_perceptual_hash: :environment do
    puts "Running deploy task 'backfill_image_perceptual_hash'"

    Galleries::Image.in_batches do |batch|
      batch
        .map { Galleries::ImagePerceptualHashJob.new(it) }
        .then { ActiveJob.perform_all_later(it) }
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
