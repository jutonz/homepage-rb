# typed: true

module Todo
  class RoomPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Todo::Room} }
  end
end
