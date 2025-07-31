# frozen_string_literal: true

module Todoist
  module Api
    class Tasks
      Task = Data.define(
        :added_at,
        :completed_at,
        :content,
        :description,
        :due,
        :id,
        :labels,
        :project_id
      ) do
        def update(...) = Todoist::Api::Tasks.update(id, ...)

        def completed? = completed_at.present?
      end

      Due = Data.define(
        :date,
        :string,
        :is_recurring
      )

      def self.get(id)
        Todoist::Api::Client
          .get("/api/v1/tasks/#{id}")
          .body
          .then { from_json(it) }
      end

      # https://developer.todoist.com/api/v1#tag/Tasks/operation/create_task_api_v1_tasks_post
      def self.create(
        content:,
        description: nil,
        project_id: nil,
        labels: [],
        due_string: nil,
        due_date: nil
      )
        params = {
          "content" => content,
          "description" => description,
          "project_id" => project_id,
          "labels" => labels,
          "due_string" => due_string,
          "due_date" => due_date
        }

        Todoist::Api::Client
          .post("/api/v1/tasks", params)
          .body
          .then { from_json(it) }
      end

      # https://developer.todoist.com/api/v1/#tag/Tasks/operation/get_tasks_by_filter_api_v1_tasks_filter_get
      def self.rollable
        params = {"query" => "@rollable,overdue"}

        Todoist::Api::Client
          .get("/api/v1/tasks/filter", params)
          .body
          .fetch("results", [])
          .map { from_json(it) }
      end

      # https://developer.todoist.com/api/v1/#tag/Tasks/operation/update_task_api_v1_tasks__task_id__post
      def self.update(id, params)
        Todoist::Api::Client
          .post("/api/v1/tasks/#{id}", params)
          .body
          .then { from_json(it) }
      end

      def self.from_json(json)
        due =
          if json["due"].present?
            Due.new(
              date: Time.parse(json.dig("due", "date")),
              string: json.dig("due", "string"),
              is_recurring: json.dig("due", "is_recurring")
            )
          end

        Task.new(
          due:,
          id: json["id"],
          content: json["content"],
          description: json["description"],
          labels: json["labels"] || [],
          project_id: json["project_id"],
          added_at: json["added_at"] ? Time.parse(json["added_at"]) : nil,
          completed_at: json["completed_at"] ? Time.parse(json["completed_at"]) : nil
        )
      end
    end
  end
end
