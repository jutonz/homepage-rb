module Api
  module Webhooks
    class TodoistController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :verify_webhook_signature

      def create
        event_name = params[:event_name]
        event_data = params[:event_data]

        case event_name
        when "item:completed"
          handle_task_completion(event_data)
        when "item:uncompleted"
          handle_task_uncompletion(event_data)
        end

        head :ok
      end

      private

      def handle_task_completion(event_data)
        todoist_task_id = event_data[:id]
        task_occurrence = Todo::TaskOccurrence.find_by(todoist_task_id:)

        if task_occurrence&.scheduled?
          task_occurrence.complete!
          broadcast_task_update(task_occurrence.todo_task)
        end
      end

      def handle_task_uncompletion(event_data)
        todoist_task_id = event_data[:id]
        task_occurrence = Todo::TaskOccurrence.find_by(todoist_task_id:)

        if task_occurrence&.completed?
          task_occurrence.update!(completed_at: nil)
          broadcast_task_update(task_occurrence.todo_task)
        end
      end

      def broadcast_task_update(task)
        task.rooms.each do |room|
          Turbo::StreamsChannel.broadcast_replace_to(
            "room_#{room.id}",
            target: "task_#{task.id}",
            partial: "todo/rooms/task_card",
            locals: {task: task, room: room}
          )
        end
      end

      def verify_webhook_signature
        signature = request.headers["X-Todoist-Hmac-SHA256"]
        payload = request.raw_post

        expected_signature =
          OpenSSL::HMAC
            .hexdigest(OpenSSL::Digest.new("sha256"), client_secret, payload)
            .then { [it].pack("H*") }
            .then { |raw| Base64.strict_encode64(raw) }

        ActiveSupport::SecurityUtils
          .secure_compare(signature, expected_signature)
          .then do |valid|
            head :unauthorized unless valid
          end
      end

      def client_secret
        Rails.application.credentials.todoist.client_secret
      end
    end
  end
end
