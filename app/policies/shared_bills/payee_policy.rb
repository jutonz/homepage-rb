# typed: strict

module SharedBills
  class PayeePolicy < UserOwnedPolicy
    Record = type_member { {fixed: SharedBills::Payee} }

    private

    sig { returns(T.nilable(User)) }
    def owner
      record.shared_bill&.user
    end
  end
end
