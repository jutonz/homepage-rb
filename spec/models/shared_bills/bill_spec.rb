# == Schema Information
#
# Table name: shared_bills_bills
# Database name: primary
#
#  id             :bigint           not null, primary key
#  period_end     :datetime         not null
#  period_start   :datetime         not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  shared_bill_id :bigint           not null
#
# Indexes
#
#  index_shared_bills_bills_on_shared_bill_id  (shared_bill_id)
#
# Foreign Keys
#
#  fk_rails_...  (shared_bill_id => shared_bills_shared_bills.id)
#
require "rails_helper"

RSpec.describe SharedBills::Bill do
  it { is_expected.to belong_to(:shared_bill) }
  it { is_expected.to have_many(:payee_bills) }
  it { is_expected.to have_many(:payees) }
  it { is_expected.to validate_presence_of(:period_start) }
  it { is_expected.to validate_presence_of(:period_end) }

  it "has a valid factory" do
    expect(build(:shared_bills_bill)).to be_valid
  end

  describe "period_end_after_period_start" do
    it "is invalid when period_end is before period_start" do
      bill = build(
        :shared_bills_bill,
        period_start: Time.current,
        period_end: 1.day.ago
      )

      bill.validate

      expect(bill.errors[:period_end])
        .to include("must be after period start")
    end

    it "is valid when period_end is after period_start" do
      bill = build(
        :shared_bills_bill,
        period_start: 1.day.ago,
        period_end: Time.current
      )

      bill.validate

      expect(bill.errors[:period_end]).to be_empty
    end

    it "does not raise when both periods are nil" do
      bill = build(:shared_bills_bill, period_start: nil, period_end: nil)

      expect { bill.validate }.not_to raise_error
    end
  end

  describe ".with_payee_info" do
    it "calculates total_amount as sum of payee_bills" do
      bill = create(:shared_bills_bill)
      create(:shared_bills_payee_bill, bill:, amount_cents: 1)
      create(:shared_bills_payee_bill, bill:, amount_cents: 2)

      result = described_class.with_payee_info.find(bill.id)

      expect(result.total_amount).to eql(3)
    end

    it "returns 0 when bill has no payee_bills" do
      bill = create(:shared_bills_bill)

      result = described_class.with_payee_info.find(bill.id)

      expect(result.total_amount).to eql(0)
    end

    it "updates total_amount when payee_bills change" do
      bill = create(:shared_bills_bill)
      payee_bill = create(:shared_bills_payee_bill, bill:, amount_cents: 1)

      result = described_class.with_payee_info.find(bill.id)
      expect(result.total_amount).to eql(1)

      payee_bill.update!(amount_cents: 2)

      result = described_class.with_payee_info.find(bill.id)
      expect(result.total_amount).to eql(2)
    end

    it "returns true for all_payees_paid when all payees have paid" do
      bill = create(
        :shared_bills_bill,
        payee_bills: build_pair(:shared_bills_payee_bill, :paid)
      )

      result = described_class.with_payee_info.find(bill.id)

      expect(result.all_payees_paid).to be(true)
    end

    it "returns false for all_payees_paid when some payees haven't paid" do
      bill = create(:shared_bills_bill)
      create(:shared_bills_payee_bill, :paid, bill:)
      create(:shared_bills_payee_bill, :unpaid, bill:)

      result = described_class.with_payee_info.find(bill.id)

      expect(result.all_payees_paid).to be(false)
    end

    it "returns false for all_payees_paid when no payees exist" do
      bill = create(:shared_bills_bill)

      result = described_class.with_payee_info.find(bill.id)

      expect(result.all_payees_paid).to be(false)
    end
  end
end
