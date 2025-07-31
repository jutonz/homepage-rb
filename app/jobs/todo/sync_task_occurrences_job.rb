module Todo
  class SyncTaskOccurrencesJob < ApplicationJob
    queue_as :default

    def perform
      active_occurrences =
        Todo::TaskOccurrence
          .scheduled
          .includes(:todo_task)

      active_occurrences.find_each do |occurrence|
        todoist_task = Todoist::Api::Tasks.get(occurrence.todoist_task_id)

        if todoist_task.completed? && occurrence.scheduled?
          occurrence.complete!

          broadcast_task_update(occurrence.todo_task)

          Rails.logger.info "Synced completion for task #{occurrence.todoist_task_id}"
        end
      rescue Faraday::ClientError => e
        if e.response&.status == 404
          Rails.logger.warn "Todoist task #{occurrence.todoist_task_id} not found, marking as completed"
          occurrence.complete!
          broadcast_task_update(occurrence.todo_task)
        else
          Rails.logger.error "Error syncing task #{occurrence.todoist_task_id}: #{e.message}"
        end
      rescue => e
        Rails.logger.error "Unexpected error syncing task #{occurrence.todoist_task_id}: #{e.message}"
      end
    end

    private

    def broadcast_task_update(task)
      task.rooms.each do |room|
        Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{room.id}",
          target: "task_#{task.id}",
          partial: "todo/rooms/task_card",
          locals: {task:, room:}
        )
      end
    end
  end
end
