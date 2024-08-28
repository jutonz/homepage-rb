# frozen_string_literal: true

module Api
  module Todoist
    class TasksController < ApplicationController
      # TODO: Check API key

      def create
        ::Todoist::Api::Tasks.create(
          **task_params.to_h.symbolize_keys,
          project_id: ::Todoist::Api::Projects::CJ_PROJECT_ID
        )

        head :ok
      end

      private

      def task_params
        params.permit(:content, :due_string)
      end
    end
  end
end
