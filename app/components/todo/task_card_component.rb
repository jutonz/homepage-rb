module Todo
  class TaskCardComponent < ApplicationComponent
    erb_template <<~ERB
      <% if @task.status == "available" %>
        <%= button_to(
          todo_task_occurrence_path(@task, room_id: @room.id),
          id: "task_\#{@task.id}",
          class: card_classes,
          data: {
            task_status: @task.status,
            role: "room",
            turbo_confirm: "Schedule this task?"
          }
        ) do %>
          <div class="text-2xl mb-4"><%= @task.name %></div>
          <div class="text-lg opacity-80">Tap to schedule</div>
        <% end %>
      <% else %>
        <div id="task_<%= @task.id %>"
             class="<%= card_classes %>"
             data-task-status="<%= @task.status %>">
          <div class="text-2xl mb-4"><%= @task.name %></div>
          <div class="text-lg opacity-80">⏳ Awaiting completion</div>
          <% if (occurrence = @task.current_occurrence) %>
            <div class="text-sm mt-2 opacity-60">
              Scheduled <%= time_ago_in_words(occurrence.scheduled_at) %> ago
            </div>
          <% end %>
        </div>
      <% end %>
    ERB

    def initialize(task:, room:)
      @task = task
      @room = room
    end

    attr_reader :task, :room

    private

    def card_classes
      base_classes = %w[
        rounded-lg p-8 text-center transition-all duration-200
        min-h-[200px] flex flex-col justify-center items-center
        text-xl font-semibold border-none
      ].join(" ")

      case task.status
      when "available"
        "#{base_classes} bg-blue-500 hover:bg-blue-600 text-white
         cursor-pointer shadow-lg hover:shadow-xl transform
         hover:scale-105 active:scale-95"
      when "scheduled"
        "#{base_classes} bg-gray-300 text-gray-600 cursor-not-allowed"
      else
        base_classes
      end
    end
  end
end
