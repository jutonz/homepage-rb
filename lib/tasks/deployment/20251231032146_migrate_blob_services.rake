namespace :after_party do
  desc "Deployment task: migrate_blob_services"
  task migrate_blob_services: :environment do
    puts "Running deploy task 'migrate_blob_services'"

    # Put your task implementation HERE.
    ActiveStorage::Blob.update_all(service_name: "mirror")
    # ActiveStorage::Blob.find_each { |blob| blob.mirror_later }

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
