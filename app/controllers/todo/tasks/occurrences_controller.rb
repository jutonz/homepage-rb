module Todo
  module Tasks
    class OccurrencesController < ApplicationController
      before_action :ensure_authenticated!

      def create
        @task = find_task
        Todoist::Api::Tasks.create(
          content: @task.name,
          labels: %w[rollable],
          due_string: "today"
        )
        redirect_to(
          todo_room_path(room_id(@task)),
          notice: "Created task :)"
        )
      end

      private

      def find_task
        @task = current_user.todo_tasks.find(params[:task_id])
      end

      def room_id(task)
        params[:room_id] || task.room_tasks.pick(:room_id)
      end
    end
  end
end
