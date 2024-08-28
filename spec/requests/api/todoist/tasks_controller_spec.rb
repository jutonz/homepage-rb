require "rails_helper"

RSpec.describe Api::Todoist::TasksController do
  describe "create" do
    it "creates a task" do
      params = {
        content: "do something",
        due_string: "today"
      }
      stub = TodoistApiMocks.mock_tasks_create

      post(api_todoist_tasks_path, params:)

      expect(response.status).to eql(200)
      expect(stub).to have_been_requested
    end
  end
end
