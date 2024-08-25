# frozen_string_literal: true

require "rails_helper"

RSpec.describe Todoist::RescheduleRollableTasks, ".perform" do
  it "reschedules tasks" do
    task = build(:todoist_api_task)
    TodoistApiMocks.mock_tasks_rollable([task])
    update_mock = TodoistApiMocks.mock_task_update(
      task,
      result: task
    )

    described_class.perform

    expect(update_mock).to have_been_requested
  end
end
