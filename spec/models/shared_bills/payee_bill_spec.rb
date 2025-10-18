# == Schema Information
#
# Table name: shared_bills_payee_bills
#
#  id           :bigint           not null, primary key
#  amount_cents :integer          not null
#  paid         :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bill_id      :bigint           not null
#  payee_id     :bigint           not null
#
# Indexes
#
#  index_shared_bills_payee_bills_on_bill_id               (bill_id)
#  index_shared_bills_payee_bills_on_bill_id_and_payee_id  (bill_id,payee_id) UNIQUE
#  index_shared_bills_payee_bills_on_payee_id              (payee_id)
#
# Foreign Keys
#
#  fk_rails_...  (bill_id => shared_bills_bills.id)
#  fk_rails_...  (payee_id => shared_bills_payees.id)
#
require "rails_helper"

RSpec.describe SharedBills::PayeeBill do
  subject { build(:shared_bills_payee_bill) }

  it { is_expected.to belong_to(:bill) }
  it { is_expected.to belong_to(:payee) }
  it { is_expected.to validate_presence_of(:amount_cents) }
  it do
    is_expected.to validate_numericality_of(:amount_cents)
      .is_greater_than_or_equal_to(0)
  end
  it do
    is_expected.to(
      validate_uniqueness_of(:payee_id).scoped_to(:bill_id)
    )
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
