require "rails_helper"

RSpec.describe Todoist::Api::Tasks do
  describe ".from_json" do
    it "converts json into an object" do
      json = {
        "user_id" => "40386552",
        "id" => "6cVrPg9WXPhx4XjX",
        "project_id" => "6JRjhMXMmhwq3WVX",
        "section_id" => nil,
        "parent_id" => nil,
        "added_by_uid" => "40386552",
        "assigned_by_uid" => nil,
        "responsible_uid" => nil,
        "labels" => ["blah"],
        "deadline" => nil,
        "duration" => nil,
        "checked" => false,
        "is_deleted" => false,
        "added_at" => "2025-07-30T11:40:04.230814Z",
        "completed_at" => nil,
        "updated_at" => "2025-07-30T11:40:04.230831Z",
        "due" => {
          "date" => "2025-07-31T11:40:04Z",
          "timezone" => "America/New_York",
          "string" => "tomorrow",
          "lang" => "en",
          "is_recurring" => false
        },
        "priority" => 1,
        "child_order" => 379,
        "content" => "hi",
        "description" => "desc",
        "note_count" => 0,
        "day_order" => -1,
        "is_collapsed" => false
      }

      result = described_class.from_json(json)

      expect(result).to eql(described_class::Task.new(
        id: "6cVrPg9WXPhx4XjX",
        project_id: "6JRjhMXMmhwq3WVX",
        labels: ["blah"],
        added_at: Time.parse("2025-07-30T11:40:04.230814Z"),
        completed_at: nil,
        content: "hi",
        description: "desc",
        due: described_class::Due.new(
          date: Time.parse("2025-07-31T11:40:04Z"),
          is_recurring: false,
          string: "tomorrow"
        )
      ))
    end

    it "handles due being blank" do
      json = {
        "user_id" => "40386552",
        "id" => "6cVrPg9WXPhx4XjX",
        "project_id" => "6JRjhMXMmhwq3WVX",
        "section_id" => nil,
        "parent_id" => nil,
        "added_by_uid" => "40386552",
        "assigned_by_uid" => nil,
        "responsible_uid" => nil,
        "labels" => ["blah"],
        "deadline" => nil,
        "duration" => nil,
        "checked" => false,
        "is_deleted" => false,
        "added_at" => "2025-07-30T11:40:04.230814Z",
        "completed_at" => nil,
        "updated_at" => "2025-07-30T11:40:04.230831Z",
        "due" => nil,
        "priority" => 1,
        "child_order" => 379,
        "content" => "hi",
        "description" => "desc",
        "note_count" => 0,
        "day_order" => -1,
        "is_collapsed" => false
      }

      result = described_class.from_json(json)

      expect(result.due).to be_nil
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
      body = {
        "results" => [
          {
            "user_id" => "40386552",
            "id" => "6cVrX2hg4JcG9GpG",
            "project_id" => "6JQqFRch3rm96F7G",
            "section_id" => nil,
            "parent_id" => nil,
            "added_by_uid" => "40386552",
            "assigned_by_uid" => nil,
            "responsible_uid" => nil,
            "labels" => ["rollable"],
            "deadline" => nil,
            "duration" => nil,
            "checked" => false,
            "is_deleted" => false,
            "added_at" => "2025-07-30T12:06:03.257775Z",
            "completed_at" => nil,
            "updated_at" => "2025-07-30T12:06:03.257792Z",
            "due" => {
              "date" => "2025-07-29",
              "timezone" => nil,
              "string" => "Jul 29",
              "lang" => "en",
              "is_recurring" => false
            },
            "priority" => 1,
            "child_order" => 55,
            "content" => "test overdue?",
            "description" => "",
            "note_count" => 0,
            "day_order" => -1,
            "is_collapsed" => false
          }
        ],
        "next_cursor" => nil
      }
      stub = FakeTodoist.stub(
        :get,
        "/api/v1/tasks/filter?query=@rollable,overdue"
      ).to_return(
        status: 200,
        headers: {"content-type" => "application/json"},
        body: body.to_json
      )

      result = described_class.rollable

      expect(stub).to have_been_requested
      expect(result.first.id).to eql("6cVrX2hg4JcG9GpG")
    end
  end

  describe ".update" do
    it "updates a task" do
      task = build(:todoist_api_task, content: "hi")
      TodoistApiMocks.mock_task_update(
        task,
        result: build(:todoist_api_task, id: task.id, content: "hi2")
      )

      result = described_class.update(task.id, {"content" => "hi2"})

      expect(result.content).to eql("hi2")
    end
  end
end
