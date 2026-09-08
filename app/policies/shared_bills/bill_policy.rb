# typed: true

module SharedBills
  class BillPolicy < UserOwnedPolicy
    Record = type_member { {fixed: SharedBills::Bill} }

    private

    def owner
      record.shared_bill&.user
    end
  end
end
