# frozen_string_literal: true

module Todoist
  module Api
    class Tasks
      Task = Data.define(
        :assignee_id,
        :assigner_id,
        :content,
        :creator_id,
        :description,
        :due,
        :id,
        :is_completed,
        :labels,
        :priority,
        :project_id
      ) do
        def update(...) = Todoist::Api::Tasks.update(id, ...)
      end

      Due = Data.define(
        :date,
        :string,
        :is_recurring
      )

      def self.get(id)
        Todoist::Api::Client
          .get("/rest/v2/tasks/#{id}")
          .body
          .then { from_json(it) }
      end

      # https://developer.todoist.com/rest/v2/#create-a-new-task
      def self.create(
        content:,
        description: nil,
        project_id: nil,
        labels: [],
        due_string: nil,
        due_date: nil
      )
        params = {"content" => content}
        params["description"] = description if description
        params["project_id"] = project_id if project_id
        params["labels"] = labels if labels
        params["due_string"] = due_string if due_string
        params["due_date"] = due_date if due_date

        Todoist::Api::Client
          .post("/rest/v2/tasks", params)
          .body
          .then { from_json(it) }
      end

      # https://developer.todoist.com/rest/v2/#get-active-tasks
      def self.rollable
        params = {"filter" => "@rollable,overdue"}

        Todoist::Api::Client
          .get("/rest/v2/tasks", params)
          .body
          .map { from_json(it) }
      end

      # https://developer.todoist.com/rest/v2/#update-a-task
      def self.update(id, params)
        Todoist::Api::Client
          .post("/rest/v2/tasks/#{id}", params)
          .body
          .then { from_json(it) }
      end

      def self.from_json(json)
        due =
          if json["due"].present?
            Due.new(
              date: Date.parse(json.dig("due", "date")),
              string: json.dig("due", "string"),
              is_recurring: json.dig("due", "is_recurring")
            )
          end

        Task.new(
          assignee_id: json["assignee_id"],
          assigner_id: json["assigner_id"],
          content: json["content"],
          creator_id: json["creator_id"],
          description: json["description"],
          due:,
          id: json["id"],
          is_completed: json["is_completed"],
          labels: json["labels"] || [],
          priority: json["priority"],
          project_id: json["project_id"]
        )
      end
    end
  end
end
