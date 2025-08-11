module Todo
  class TaskOccurrencePolicy < ApplicationPolicy
    def create?
      user_owns_task?
    end

    private

    def user_owns_task?
      user && record.todo_task.user == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.joins(:todo_task).where(todo_tasks: {user:})
      end
    end
  end
end
