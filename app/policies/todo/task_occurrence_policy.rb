# typed: true

module Todo
  class TaskOccurrencePolicy < ApplicationPolicy
    Record = type_member { {fixed: Todo::TaskOccurrence} }

    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none unless user

      model.joins(:todo_task).where(todo_tasks: {user:})
    end

    def create?
      user_owns_task?
    end

    private

    def user_owns_task?
      user && record.todo_task&.user == user
    end
  end
end
