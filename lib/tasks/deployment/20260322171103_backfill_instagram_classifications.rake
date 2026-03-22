namespace :after_party do
  desc "Deployment task: backfill_instagram_classifications"
  task backfill_instagram_classifications: :environment do
    puts "Running deploy task 'backfill_instagram_classifications'"

    Galleries::Tag
      .joins(:social_media_links)
      .where(
        galleries_social_media_links: {platform: "instagram"}
      )
      .where.not(classification: "subject")
      .find_each { it.update!(classification: "subject") }

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
