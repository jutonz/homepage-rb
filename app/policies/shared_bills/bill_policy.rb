module SharedBills
  class BillPolicy < UserOwnedPolicy
    private

    def owner
      record.shared_bill.user
    end
  end
end
