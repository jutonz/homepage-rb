module Todo
  class TasksController < ApplicationController
    before_action :ensure_authenticated!

    def index
      @tasks = current_user.todo_tasks
    end

    def new
      @task = Task.new(task_params)
    end

    def create
      @task = current_user.todo_tasks.new(task_params)

      if @task.save
        redirect_to(todo_tasks_path, notice: "Created task")
      else
        render :new, status: :unprocessable_content
      end
    end

    def show
      @task = find_task
    end

    def edit
      @task = find_task
    end

    def update
      @task = find_task

      if @task.update(task_params)
        redirect_to(todo_task_path(@task), notice: "Updated task")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      find_task.destroy
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
      current_user.todo_tasks.find(params[:id])
    end
  end
end
