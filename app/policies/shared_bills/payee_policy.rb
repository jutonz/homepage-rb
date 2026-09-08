# typed: true

module SharedBills
  class PayeePolicy < UserOwnedPolicy
    Record = type_member { {fixed: SharedBills::Payee} }

    private

    def owner
      record.shared_bill&.user
    end
  end
end
