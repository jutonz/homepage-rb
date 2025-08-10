module Todo
  module Tasks
    class OccurrencesController < ApplicationController
      before_action :ensure_authenticated!
      after_action :verify_authorized

      def create
        @task = find_task

        unless @task.available_for_scheduling?
          redirect_to(
            todo_room_path(room_id(@task)),
            alert: "Task is already scheduled"
          )
          return
        end

        todoist_task = Todoist::Api::Tasks.create(
          content: @task.name,
          labels: %w[rollable],
          due_string: "today",
          project_id: Todoist::Api::Projects::CJ_PROJECT_ID
        )

        @task_occurrence = authorize(@task.task_occurrences.build(
          todoist_task_id: todoist_task.id,
          scheduled_at: Time.current
        ))

        @task_occurrence.save!
        broadcast_task_update(@task)

        redirect_to(
          todo_room_path(room_id(@task)),
          notice: "Created task :)"
        )
      end

      private

      def find_task
        @task = policy_scope(Todo::Task).find(params[:task_id])
      end

      def room_id(task)
        params[:room_id] || task.room_tasks.pick(:room_id)
      end

      def broadcast_task_update(task)
        task.rooms.each do |room|
          Turbo::StreamsChannel.broadcast_replace_to(
            "room_#{room.id}",
            target: "task_#{task.id}",
            partial: "todo/rooms/task_card",
            locals: {task: task, room: room}
          )
        end
      end
    end
  end
end
