module Todoist
  class RescheduleRollableTasksJob < ApplicationJob
    queue_as :background

    retry_on Faraday::ServerError

    def perform
      Todoist::RescheduleRollableTasks.perform
    end
  end
end
