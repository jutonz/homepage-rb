# typed: strict

module SharedBills
  class BillPolicy < UserOwnedPolicy
    Record = type_member { {fixed: SharedBills::Bill} }

    private

    sig { returns(T.nilable(User)) }
    def owner
      record.shared_bill&.user
    end
  end
end
