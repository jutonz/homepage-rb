namespace :after_party do
  desc "Deployment task: backfill_image_processed"
  task backfill_image_processed: :environment do
    puts "Running deploy task 'backfill_image_processed'"

    Galleries::Image
      .where(processed_at: nil)
      .in_batches
      .update_all(processed_at: Time.current)

    AfterParty::TaskRecord
      .create(
        version: AfterParty::TaskRecorder
          .new(__FILE__).timestamp
      )
  end
end
