require "rails_helper"

RSpec.describe Todo::Tasks::OccurrencesController do
  describe "#create" do
    it "creates a task and redirects" do
      api_task = build(:todoist_api_task)
      mock = TodoistApiMocks.mock_tasks_create(api_task)
      task = create(:todo_task, :with_room)
      room_id = task.room_ids.first
      login_as(task.user)

      post(todo_task_occurrence_path(task, room_id:))

      expect(response).to redirect_to(todo_room_path(room_id))
      expect(mock).to have_been_requested
    end

    it "redirects to the task's first room_id if none is supplied" do
      api_task = build(:todoist_api_task)
      mock = TodoistApiMocks.mock_tasks_create(api_task)
      task = create(:todo_task, :with_room)
      room_id = task.room_ids.first
      login_as(task.user)

      post(todo_task_occurrence_path(task))

      expect(response).to redirect_to(todo_room_path(room_id))
      expect(mock).to have_been_requested
    end

    it "returns 404 when creating occurrence for task not owned by current user" do
      task = create(:todo_task, :with_room)
      other_user = create(:user)
      login_as(other_user)

      post(todo_task_occurrence_path(task))

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      task = create(:todo_task, :with_room)

      post(todo_task_occurrence_path(task))

      expect(response).to redirect_to(new_session_path)
    end
  end
end
