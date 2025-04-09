module Todoist
  class RescheduleRollableTasks
    def self.perform(...) = new(...).perform

    def initialize
      @tasks = Todoist::Api::Tasks.rollable
    end

    def perform
      tasks.map { rescheule_task(it) }
    end

    private

    attr_reader :tasks

    def rescheule_task(task)
      tomorrow = (task.due.date + 1.day).iso8601

      task.update({
        "due_string" => task.due.string,
        "due_date" => tomorrow
      })
    end
  end
end
