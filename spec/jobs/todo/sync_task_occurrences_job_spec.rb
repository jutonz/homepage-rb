require "rails_helper"

RSpec.describe Todo::SyncTaskOccurrencesJob, type: :job do
  describe "#perform" do
    it "completes task occurrence when todoist task is completed" do
      user = create(:user)
      room = create(:todo_room, user:)
      task = create(:todo_task, user:)
      create(:todo_room_task, room:, task:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      completed_todoist_task = build(:todoist_api_task, completed_at: Time.current)
      allow(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_return(completed_todoist_task)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

      freeze_time do
        described_class.new.perform

        expect(task_occurrence.reload.completed_at).to be_within(1.second).of(Time.current)
      end
    end

    it "broadcasts task update to all rooms when task is completed" do
      user = create(:user)
      room = create(:todo_room, user:)
      task = create(:todo_task, user:)
      create(:todo_room_task, room:, task:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      completed_todoist_task = build(:todoist_api_task, completed_at: Time.current)
      allow(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_return(completed_todoist_task)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

      described_class.new.perform

      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "room_#{room.id}",
        target: "task_#{task.id}",
        partial: "todo/rooms/task_card",
        locals: {task:, room:}
      )
    end

    it "logs sync completion" do
      user = create(:user)
      task = create(:todo_task, user:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      completed_todoist_task = build(:todoist_api_task, completed_at: Time.current)
      allow(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_return(completed_todoist_task)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      allow(Rails.logger).to receive(:info)

      described_class.new.perform

      expect(Rails.logger).to have_received(:info)
        .with("Synced completion for task #{task_occurrence.todoist_task_id}")
    end

    it "does not complete task occurrence when todoist task is not completed" do
      user = create(:user)
      task = create(:todo_task, user:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      incomplete_todoist_task = build(:todoist_api_task, completed_at: nil)
      expect(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_return(incomplete_todoist_task)
      expect(Turbo::StreamsChannel).not_to receive(:broadcast_replace_to)

      described_class.new.perform

      expect(task_occurrence.reload.completed_at).to be_nil
    end

    it "completes task occurrence when todoist task is not found (404 error)" do
      user = create(:user)
      room = create(:todo_room, user:)
      task = create(:todo_task, user:)
      create(:todo_room_task, room:, task:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      response = double("Response", status: 404)
      error = Faraday::ClientError.new("Not found", response)
      allow(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_raise(error)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

      freeze_time do
        described_class.new.perform

        expect(task_occurrence.reload.completed_at).to be_within(1.second).of(Time.current)
      end
    end

    it "logs warning when todoist task is not found" do
      user = create(:user)
      task = create(:todo_task, user:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      response = double("Response", status: 404)
      error = Faraday::ClientError.new("Not found", response)
      allow(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_raise(error)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      allow(Rails.logger).to receive(:warn)

      described_class.new.perform

      expect(Rails.logger).to have_received(:warn)
        .with("Todoist task #{task_occurrence.todoist_task_id} not found, marking as completed")
    end

    it "does not complete task occurrence on non-404 client error" do
      user = create(:user)
      room = create(:todo_room, user:)
      task = create(:todo_task, user:)
      create(:todo_room_task, room:, task:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      response = double("Response", status: 500)
      error = Faraday::ClientError.new("Server error", response)
      allow(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_raise(error)
      allow(Rails.logger).to receive(:error)

      described_class.new.perform

      expect(task_occurrence.reload.completed_at).to be_nil
      expect(Rails.logger).to have_received(:error)
        .with("Error syncing task #{task_occurrence.todoist_task_id}: Server error")
    end

    it "does not complete task occurrence on unexpected error" do
      user = create(:user)
      room = create(:todo_room, user:)
      task = create(:todo_task, user:)
      create(:todo_room_task, room:, task:)
      task_occurrence = create(:todo_task_occurrence, todo_task: task)

      allow(Todoist::Api::Tasks).to receive(:get)
        .with(task_occurrence.todoist_task_id)
        .and_raise(StandardError, "Unexpected error")
      allow(Rails.logger).to receive(:error)

      described_class.new.perform

      expect(task_occurrence.reload.completed_at).to be_nil
      expect(Rails.logger).to have_received(:error)
        .with("Unexpected error syncing task #{task_occurrence.todoist_task_id}: Unexpected error")
    end

    it "does not process already completed task occurrences" do
      user = create(:user)
      task = create(:todo_task, user:)
      create(:todo_task_occurrence, :completed, todo_task: task)

      allow(Todoist::Api::Tasks).to receive(:get)

      described_class.new.perform

      expect(Todoist::Api::Tasks).not_to have_received(:get)
    end

    it "only processes scheduled occurrences when multiple exist" do
      user = create(:user)
      task = create(:todo_task, user:)
      scheduled_occurrence = create(:todo_task_occurrence, todo_task: task)
      completed_occurrence = create(:todo_task_occurrence, :completed, todo_task: task)

      completed_todoist_task = build(:todoist_api_task, completed_at: Time.current)
      allow(Todoist::Api::Tasks).to receive(:get)
        .with(scheduled_occurrence.todoist_task_id)
        .and_return(completed_todoist_task)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

      described_class.new.perform

      expect(Todoist::Api::Tasks).to have_received(:get).once
      expect(scheduled_occurrence.reload.completed_at).to be_present
      expect(completed_occurrence.reload.completed_at).to be_present # unchanged
    end
  end
end
