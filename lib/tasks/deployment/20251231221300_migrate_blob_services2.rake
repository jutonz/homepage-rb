namespace :after_party do
  desc "Deployment task: migrate_blob_services2"
  task migrate_blob_services2: :environment do
    puts "Running deploy task 'migrate_blob_services2'"

    ActiveStorage::Blob.update_all(service_name: "block")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
