require "rails_helper"

RSpec.describe Todoist::RescheduleRollableTasksJob do
  include ActiveJob::TestHelper

  it "reschedules jobs" do
    allow(Todoist::RescheduleRollableTasks).to receive(:perform)

    described_class.new.perform

    expect(Todoist::RescheduleRollableTasks).to have_received(:perform)
  end

  it "retries if a server error occurs" do
    allow(Todoist::RescheduleRollableTasks)
      .to receive(:perform)
      .and_raise(Faraday::ServerError)

    perform_enqueued_jobs do
      described_class.perform_now
    rescue Faraday::ServerError
      nil # perform_enqueued_jobs will complain if an exception is raised
    end

    expect(Todoist::RescheduleRollableTasks)
      .to have_received(:perform)
      .exactly(5).times
  end
end
