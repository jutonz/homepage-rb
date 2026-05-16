require "rails_helper"
require "rake"

unless Rake::Task.task_defined?("after_party:backfill_video_posters")
  Rails.application.load_tasks
end

RSpec.describe "after_party:backfill_video_posters" do
  it "enqueues ImageProcessingJob only for video images" do
    video = create(:galleries_image, :webm)
    non_video = create(:galleries_image)
    task = Rake::Task["after_party:backfill_video_posters"]
    task.reenable

    task.invoke

    expect(Galleries::ImageProcessingJob)
      .to have_been_enqueued.with(video)
    expect(Galleries::ImageProcessingJob)
      .not_to have_been_enqueued.with(non_video)
  end
end
