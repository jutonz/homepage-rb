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

      expect(form.name).to be_nil
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
      bill = create(:shared_bills_bill, shared_bill:, name: "January")
      create(:shared_bills_payee_bill, bill:, payee: payee1, amount: 1000)

      form = described_class.new(bill:, shared_bill:)

      expect(form.name).to eql("January")
      expect(form.payee_amounts[payee1.id.to_s][:selected]).to be(true)
      expect(form.payee_amounts[payee1.id.to_s][:amount]).to eql(1000)
      expect(form.payee_amounts[payee2.id.to_s]).to be_nil
    end
  end

  describe "validations" do
    it "validates presence of name" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.name = ""
      form.payee_amounts = {
        payee.id.to_s => {selected: true, amount: 1000}
      }

      expect(form.valid?).to be(false)
      expect(form.errors[:name]).to include("can't be blank")
    end

    it "validates at least one payee is selected" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.name = "January"
      form.payee_amounts = {
        payee.id.to_s => {selected: false, amount: 1000}
      }

      expect(form.valid?).to be(false)
      expect(form.errors[:base]).to include("must select at least one payee")
    end

    it "validates selected payees have amounts" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:, name: "Payee1")
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.name = "January"
      form.payee_amounts = {
        payee.id.to_s => {selected: true, amount: nil}
      }

      expect(form.valid?).to be(false)
      expect(form.errors[:base]).to include("Payee1 must have an amount")
    end

    it "validates selected payees have positive amounts" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee = create(:shared_bills_payee, shared_bill:, name: "Payee1")
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.name = "January"
      form.payee_amounts = {
        payee.id.to_s => {selected: true, amount: 0}
      }

      expect(form.valid?).to be(false)
      expect(form.errors[:base]).to include(
        "Payee1 amount must be greater than 0"
      )
    end
  end

  describe "#save" do
    it "saves a new bill with payee bills" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:, name: "Payee1")
      payee2 = create(:shared_bills_payee, shared_bill:, name: "Payee2")
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.name = "January"
      form.payee_amounts = {
        payee1.id.to_s => {selected: true, amount: 1000},
        payee2.id.to_s => {selected: true, amount: 1500}
      }

      expect(form.save).to be(true)
      expect(bill.persisted?).to be(true)
      expect(bill.name).to eql("January")
      expect(bill.payee_bills.count).to eql(2)

      pb1 = bill.payee_bills.find_by(payee: payee1)
      expect(pb1.amount).to eql(1000)
      expect(pb1.paid).to be(false)

      pb2 = bill.payee_bills.find_by(payee: payee2)
      expect(pb2.amount).to eql(1500)
      expect(pb2.paid).to be(false)
    end

    it "saves bill with only selected payees" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      payee1 = create(:shared_bills_payee, shared_bill:, name: "Payee1")
      payee2 = create(:shared_bills_payee, shared_bill:, name: "Payee2")
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.name = "January"
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
      payee1 = create(:shared_bills_payee, shared_bill:, name: "Payee1")
      payee2 = create(:shared_bills_payee, shared_bill:, name: "Payee2")
      bill = create(:shared_bills_bill, shared_bill:, name: "January")
      old_pb = create(
        :shared_bills_payee_bill,
        bill:,
        payee: payee1,
        amount: 1000
      )
      form = described_class.new(bill:, shared_bill:)

      form.name = "February"
      form.payee_amounts = {
        payee2.id.to_s => {selected: true, amount: 2000}
      }

      expect(form.save).to be(true)
      expect(bill.reload.name).to eql("February")
      expect(bill.payee_bills.count).to eql(1)
      expect(SharedBills::PayeeBill.exists?(old_pb.id)).to be(false)
      expect(bill.payee_bills.first.payee).to eql(payee2)
      expect(bill.payee_bills.first.amount).to eql(2000)
    end

    it "returns false when invalid" do
      user = create(:user)
      shared_bill = create(:shared_bill, user:)
      bill = shared_bill.bills.new
      form = described_class.new(bill:, shared_bill:)

      form.name = ""
      form.payee_amounts = {}

      expect(form.save).to be(false)
      expect(bill.persisted?).to be(false)
    end
  end
end
