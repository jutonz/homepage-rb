# typed: true

module SharedBills
  class SharedBillPolicy < UserOwnedPolicy
    Record = type_member { {fixed: SharedBills::SharedBill} }
  end
end
