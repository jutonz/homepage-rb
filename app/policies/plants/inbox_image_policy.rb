module Plants
  class InboxImagePolicy < UserOwnedPolicy
    def assign?
      user_owns_record?
    end
  end
end
