namespace :after_party do
  desc "Deployment task: regenerate_image_perceptual_hashes"
  task regenerate_image_perceptual_hashes: :environment do
    puts "Running deploy task 'regenerate_image_perceptual_hashes'"

    Galleries::Image
      .where.not(id: Galleries::Image.videos)
      .in_batches do |batch|
        batch
          .map { Galleries::PerceptualHashJob.new(it) }
          .then { ActiveJob.perform_all_later(it) }
      end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
