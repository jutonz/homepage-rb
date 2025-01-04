namespace :after_party do
  desc "Deployment task: backfill_tagging_needed_tag"
  task backfill_tagging_needed_tag: :environment do
    puts "Running deploy task 'backfill_tagging_needed_tag'"

    Gallery.find_each do |gallery|
      tagging_needed =
        gallery
          .tags
          .create_with(user: gallery.user)
          .find_or_create_by(name: "tagging needed")

      gallery
        .images
        .where.missing(:tags)
        .find_each do |image|
          image.add_tag(tagging_needed)
        end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
