require "rails_helper"

RSpec.describe SharedBills::PayeePolicy do
  permissions :show?, :update?, :destroy? do
    it "grants access when user owns the shared bill" do
      user = build(:user)
      shared_bill = build(:shared_bill, user:)
      payee = build(:shared_bills_payee, shared_bill:)

      expect(described_class).to permit(user, payee)
    end

    it "denies access when user does not own the shared bill" do
      user, other_user = build_pair(:user)
      shared_bill = build(:shared_bill, user: other_user)
      payee = build(:shared_bills_payee, shared_bill:)

      expect(described_class).not_to permit(user, payee)
    end

    it "denies access when the shared bill is missing" do
      user = build(:user)
      payee = build(:shared_bills_payee, shared_bill: nil)

      expect(described_class).not_to permit(user, payee)
    end
  end
end
