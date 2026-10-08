require "rails_helper"

RSpec.describe SharedBills::BillForm do
  describe "#initialize" do
    it "initializes with a new bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:)
      payee2 = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new

      form = described_class.new(bill:, shared_bill:)

      expect(form.payee_amounts.keys).to match_array([
        payee1.id.to_s,
        payee2.id.to_s
      ])
      expect(form.payee_amounts[payee1.id.to_s][:selected]).to be(true)
      expect(form.payee_amounts[payee1.id.to_s][:amount]).to be_nil
    end

    it "initializes with an existing bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:)
      payee2 = create(:shared_bills_payee, shared_bill:)
      bill = create(:shared_bills_bill, shared_bill:)
      create(
        :shared_bills_payee_bill,
        bill:,
        payee: payee1,
        amount_cents: 1000
      )

      form = described_class.new(bill:, shared_bill:)

      expect(form.payee_amounts[payee1.id.to_s][:selected]).to be(true)
      expect(form.payee_amounts[payee1.id.to_s][:amount]).to eql(1000)
      expect(form.payee_amounts[payee2.id.to_s]).to be_nil
    end

    it "keeps the paid state of an existing bill's payees" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      paid_payee = create(:shared_bills_payee, shared_bill:)
      unpaid_payee = create(:shared_bills_payee, shared_bill:)
      bill = create(:shared_bills_bill, shared_bill:)
      create(:shared_bills_payee_bill, bill:, payee: paid_payee, paid: true)
      create(:shared_bills_payee_bill, bill:, payee: unpaid_payee, paid: false)

      form = described_class.new(bill:, shared_bill:)

      expect(form.payee_amounts[paid_payee.id.to_s][:paid]).to be(true)
      expect(form.payee_amounts[unpaid_payee.id.to_s][:paid]).to be(false)
    end
  end

  describe "validations" do
    it "validates selected payees have amounts" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.period_start = 1.month.ago
      form.period_end = Time.current
      form.payee_amounts = {
        payee.id.to_s => {selected: true, amount: nil}
      }

      expect(form.save).to be(false)
      expect(form.errors[:amount_cents]).to eql(
        ["can't be blank, is not a number"]
      )
    end

    it "validates selected payees have positive amounts" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.period_start = 1.month.ago
      form.period_end = Time.current
      form.payee_amounts = {
        payee.id.to_s => {selected: true, amount: 0}
      }

      expect(form.save).to be(false)
      expect(form.errors[:amount_cents]).to eql(["must be greater than 0"])
    end

    it "errors if payee_id doesn't belong to the SharedBill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      other_payee = create(:shared_bills_payee)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.payee_amounts = {
        other_payee.id.to_s => {selected: true, amount: 1}
      }

      expect(form.valid?).to be(false)
      expect(form.errors[:payee_id]).to eql(["must belong to shared bill"])
    end
  end

  describe "#save" do
    it "saves a new bill with payee bills" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:)
      payee2 = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.period_start = 1.month.ago
      form.period_end = Time.current
      form.payee_amounts = {
        payee1.id.to_s => {selected: true, amount: 1000},
        payee2.id.to_s => {selected: true, amount: 1500}
      }

      expect(form.save).to be(true)
      expect(bill.persisted?).to be(true)
      expect(bill.payee_bills.count).to eql(2)

      pb1 = bill.payee_bills.find_by(payee: payee1)
      expect(pb1.amount_cents).to eql(1000)
      expect(pb1.paid).to be(false)

      pb2 = bill.payee_bills.find_by(payee: payee2)
      expect(pb2.amount_cents).to eql(1500)
      expect(pb2.paid).to be(false)
    end

    it "persists the submitted period" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)
      period_start = Time.zone.parse("2026-01-01")
      period_end = Time.zone.parse("2026-01-31")
      form.assign(
        period_start:,
        period_end:,
        payee_amounts: {payee.id.to_s => {selected: "1", amount: 1000}}
      )

      result = form.save

      expect(result).to be(true)
      expect(bill.reload.period_start).to eql(period_start)
      expect(bill.reload.period_end).to eql(period_end)
    end

    it "does not save a payee from another shared bill" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      other_payee = create(:shared_bills_payee)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)
      form.assign(
        period_start: 1.month.ago,
        period_end: Time.current,
        payee_amounts: {
          payee.id.to_s => {selected: "1", amount: 1000},
          other_payee.id.to_s => {selected: "1", amount: 1000}
        }
      )

      result = form.save

      expect(result).to be(false)
      expect(bill.persisted?).to be(false)
      expect(SharedBills::PayeeBill.count).to eql(0)
    end

    it "skips a payee whose selected value is \"0\"" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      selected_payee = create(:shared_bills_payee, shared_bill:)
      unselected_payee = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)
      form.assign(
        period_start: 1.month.ago,
        period_end: Time.current,
        payee_amounts: {
          selected_payee.id.to_s => {selected: "1", amount: 1000},
          unselected_payee.id.to_s => {selected: "0", amount: 1500}
        }
      )

      result = form.save

      expect(result).to be(true)
      expect(bill.payees).to contain_exactly(selected_payee)
    end

    it "saves bill with only selected payees" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:)
      payee2 = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.period_start = 1.month.ago
      form.period_end = Time.current
      form.payee_amounts = {
        payee1.id.to_s => {selected: true, amount: 1000},
        payee2.id.to_s => {selected: false, amount: 1500}
      }

      expect(form.save).to be(true)
      expect(bill.payee_bills.count).to eql(1)
      expect(bill.payee_bills.first.payee).to eql(payee1)
    end

    it "updates an existing bill and replaces payee bills" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:)
      payee2 = create(:shared_bills_payee, shared_bill:)
      bill = create(:shared_bills_bill, shared_bill:)
      old_pb = create(
        :shared_bills_payee_bill,
        bill:,
        payee: payee1,
        amount_cents: 1000
      )
      form = described_class.new(bill:, shared_bill:)

      form.period_start = 1.month.ago
      form.period_end = Time.current
      form.payee_amounts = {
        payee2.id.to_s => {selected: true, amount: 2000, paid: true}
      }

      expect(form.save).to be(true)
      expect(bill.payee_bills.count).to eql(1)
      expect(SharedBills::PayeeBill.exists?(old_pb.id)).to be(false)
      expect(bill.payee_bills.first.payee).to eql(payee2)
      expect(bill.payee_bills.first.amount_cents).to eql(2000)
      expect(bill.payee_bills.first.paid).to be(true)
    end

    it "saves paid status for payee bills" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:)
      payee2 = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.assign(
        period_start: 1.month.ago,
        period_end: Time.current,
        payee_amounts: {
          payee1.id.to_s => {selected: true, amount: 1000, paid: true},
          payee2.id.to_s => {selected: true, amount: 1500, paid: false}
        }
      )

      expect(form.save).to be(true)
      pb1 = bill.payee_bills.find_by(payee: payee1)
      expect(pb1.paid).to be(true)

      pb2 = bill.payee_bills.find_by(payee: payee2)
      expect(pb2.paid).to be(false)
    end

    it "returns false when invalid" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.period_start = 1.month.ago
      form.period_end = nil
      form.payee_amounts = {}

      expect(form.save).to be(false)
      expect(bill.persisted?).to be(false)
    end

    it "saves a bill without payee amounts" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)
      form.assign(period_start: 1.month.ago, period_end: Time.current)

      result = form.save

      expect(result).to be(true)
      expect(bill.payee_bills).to be_empty
    end
  end
end
