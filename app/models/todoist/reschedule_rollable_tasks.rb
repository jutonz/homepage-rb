module Todoist
  class RescheduleRollableTasks
    def self.perform(...) = new(...).perform

    def initialize
      @tasks = Todoist::Api::Tasks.rollable
    end

    def perform
      tasks.each { rescheule_task(_1) }
    end

    private

    attr_reader :tasks

    def rescheule_task(task)
      task.update({"due_string" => "tomorrow"})
    end
  end
end
