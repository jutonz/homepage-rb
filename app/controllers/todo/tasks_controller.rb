module Todo
  class TasksController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      authorize Todo::Task
      @tasks = policy_scope(Todo::Task)
    end

    def new
      @task = authorize(current_user.todo_tasks.build(task_params))
    end

    def create
      @task = authorize(current_user.todo_tasks.new(task_params))

      if @task.save
        redirect_to(todo_tasks_path, notice: "Created task")
      else
        render :new, status: :unprocessable_content
      end
    end

    def show
      @task = authorize(find_task)
    end

    def edit
      @task = authorize(find_task)
    end

    def update
      @task = authorize(find_task)

      if @task.update(task_params)
        redirect_to(todo_task_path(@task), notice: "Updated task")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize(find_task).destroy
      redirect_to(todo_tasks_path, notice: "Deleted task")
    end

    private

    def task_params
      params.fetch(:todo_task, {}).permit(:name, room_ids: []).tap do |p|
        if (room_ids = p[:room_ids]).present?
          p[:room_ids] =
            current_user
              .todo_rooms
              .where(id: room_ids)
              .pluck(:id)
        end
      end
    end

    def find_task
      policy_scope(Todo::Task).find(params[:id])
    end
  end
end
