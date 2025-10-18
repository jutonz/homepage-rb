# == Schema Information
#
# Table name: shared_bills_bills
#
#  id             :bigint           not null, primary key
#  name           :string           not null
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
  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:shared_bills_bill)).to be_valid
  end

  describe ".with_total_amount" do
    it "calculates total_amount as sum of payee_bills" do
      bill = create(:shared_bills_bill)
      create(:shared_bills_payee_bill, bill:, amount: 1)
      create(:shared_bills_payee_bill, bill:, amount: 2)

      result = described_class.with_total_amount.find(bill.id)

      expect(result.total_amount).to eql(3)
    end

    it "returns 0 when bill has no payee_bills" do
      bill = create(:shared_bills_bill)

      result = described_class.with_total_amount.find(bill.id)

      expect(result.total_amount).to eql(0)
    end

    it "updates total_amount when payee_bills change" do
      bill = create(:shared_bills_bill)
      payee_bill = create(:shared_bills_payee_bill, bill:, amount: 1)

      result = described_class.with_total_amount.find(bill.id)
      expect(result.total_amount).to eql(1)

      payee_bill.update!(amount: 2)

      result = described_class.with_total_amount.find(bill.id)
      expect(result.total_amount).to eql(2)
    end
  end
end
