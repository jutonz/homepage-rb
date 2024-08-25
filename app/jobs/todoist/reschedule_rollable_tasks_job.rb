module Todoist
  class RescheduleRollableTasksJob < ApplicationJob
    queue_as :background

    def perform
      Todoist::RescheduleRollableTasks.perform
    end
  end
end
