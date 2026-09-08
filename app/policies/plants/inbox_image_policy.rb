# typed: true

module Plants
  class InboxImagePolicy < UserOwnedPolicy
    Record = type_member { {fixed: Plants::InboxImage} }

    def assign?
      user_owns_record?
    end
  end
end
