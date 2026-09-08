# typed: true

module Todo
  class TaskPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Todo::Task} }
  end
end
