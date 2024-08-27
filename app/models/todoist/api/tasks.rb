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

      # https://developer.todoist.com/rest/v2/#get-active-tasks
      def self.rollable
        params = {"filter" => "@rollable,today"}

        Todoist::Api::Client
          .get("/rest/v2/tasks", params)
          .body
          .map { from_json(_1) }
      end

      # https://developer.todoist.com/rest/v2/#update-a-task
      def self.update(id, params)
        Todoist::Api::Client
          .post("/rest/v2/tasks/#{id}", params)
          .body
          .then { from_json(_1) }
      end

      def self.from_json(json)
        Task.new(
          assignee_id: json["assignee_id"],
          assigner_id: json["assigner_id"],
          content: json["content"],
          creator_id: json["creator_id"],
          description: json["description"],
          id: json["id"],
          is_completed: json["is_completed"],
          priority: json["priority"],
          project_id: json["project_id"],
          due: Due.new(
            date: Date.parse(json.dig("due", "date")),
            string: json.dig("due", "string"),
            is_recurring: json.dig("due", "is_recurring")
          )
        )
      end
    end
  end
end
