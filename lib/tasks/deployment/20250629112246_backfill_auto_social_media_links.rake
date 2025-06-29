namespace :after_party do
  desc "Deployment task: backfill_auto_social_media_links"
  task backfill_auto_social_media_links: :environment do
    puts "Running deploy task 'backfill_auto_social_media_links'"

    # Put your task implementation HERE.
    Galleries::Tag
      .where("name LIKE 'IG:%' OR name LIKE 'TT:%'")
      .find_each { it.auto_create_social_links }

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
