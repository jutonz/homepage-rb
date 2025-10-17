module SharedBills
  class PayeePolicy < UserOwnedPolicy
    private

    def owner
      record.shared_bill.user
    end
  end
end
