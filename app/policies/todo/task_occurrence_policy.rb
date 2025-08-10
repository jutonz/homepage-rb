module Todo
  class TaskOccurrencePolicy < ApplicationPolicy
    def create?
      user.present? && user_owns_task?
    end

    def update?
      user.present? && user_owns_task?
    end

    def destroy?
      user.present? && user_owns_task?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.joins(:todo_task).where(todo_tasks: {user:})
      end
    end

    private

    def user_owns_task?
      return false unless record.respond_to?(:todo_task)
      return false unless record.todo_task

      record.todo_task.user == user
    end
  end
end
