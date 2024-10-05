require "rails_helper"

RSpec.describe Todoist::Api::Tasks do
  describe ".from_json" do
    it "converts json into an object" do
      json = {
        "assignee_id" => "123",
        "assigner_id" => "123",
        "content" => "123",
        "creator_id" => "123",
        "description" => "123",
        "id" => "123",
        "is_completed" => "123",
        "labels" => ["rollable"],
        "priority" => "123",
        "project_id" => "123",
        "due" => {
          "date" => "2024-08-26",
          "is_recurring" => false,
          "string" => "tomorrow"
        }
      }

      result = described_class.from_json(json)

      expect(result).to eql(described_class::Task.new(
        assignee_id: "123",
        assigner_id: "123",
        content: "123",
        creator_id: "123",
        description: "123",
        id: "123",
        is_completed: "123",
        labels: ["rollable"],
        priority: "123",
        project_id: "123",
        due: described_class::Due.new(
          date: Date.parse("2024-08-26"),
          is_recurring: false,
          string: "tomorrow"
        )
      ))
    end

    it "handles due being blank" do
      json = {
        "assignee_id" => "123",
        "assigner_id" => "123",
        "content" => "123",
        "creator_id" => "123",
        "description" => "123",
        "id" => "123",
        "is_completed" => "123",
        "priority" => "123",
        "project_id" => "123",
        "due" => nil
      }

      result = described_class.from_json(json)

      expect(result).to eql(described_class::Task.new(
        assignee_id: "123",
        assigner_id: "123",
        content: "123",
        creator_id: "123",
        description: "123",
        id: "123",
        is_completed: "123",
        priority: "123",
        project_id: "123",
        due: nil,
        labels: []
      ))
    end
  end

  describe ".get" do
    it "returns a task" do
      task = build(:todoist_api_task, content: "hi")
      mock = TodoistApiMocks.mock_tasks_get(task)

      result = described_class.get(task.id)

      expect(mock).to have_been_requested
      expect(result.content).to eql("hi")
    end
  end

  describe ".create" do
    it "creates a task" do
      task = build(:todoist_api_task, content: "hi")
      mock = TodoistApiMocks.mock_tasks_create(task)

      result = described_class.create(content: "hi")

      expect(mock).to have_been_requested
      expect(result.content).to eql("hi")
    end
  end

  describe ".rollable" do
    it "returns rollable tasks due today" do
      task = build(:todoist_api_task)
      mock = TodoistApiMocks.mock_tasks_rollable(task)

      result = described_class.rollable

      expect(mock).to have_been_requested
      expect(result).to eql([task])
    end
  end

  describe ".update" do
    it "updates a task" do
      task = build(:todoist_api_task, priority: 4)
      TodoistApiMocks.mock_task_update(
        task,
        result: build(:todoist_api_task, id: task.id, priority: 1)
      )

      result = described_class.update(task.id, {"priority" => 1})

      expect(result.priority).to eql(1)
    end
  end
end
