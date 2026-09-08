require "rails_helper"

RSpec.describe SharedBills::BillPolicy do
  permissions :show?, :update?, :destroy? do
    it "grants access when user owns the shared bill" do
      user = build(:user)
      shared_bill = build(:shared_bill, user:)
      bill = build(:shared_bills_bill, shared_bill:)

      expect(described_class).to permit(user, bill)
    end

    it "denies access when user does not own the shared bill" do
      user, other_user = build_pair(:user)
      shared_bill = build(:shared_bill, user: other_user)
      bill = build(:shared_bills_bill, shared_bill:)

      expect(described_class).not_to permit(user, bill)
    end

    it "denies access when the shared bill is missing" do
      user = build(:user)
      bill = build(:shared_bills_bill, shared_bill: nil)

      expect(described_class).not_to permit(user, bill)
    end
  end
end
