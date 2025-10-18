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
module SharedBills
  class PayeeBill < ActiveRecord::Base
    belongs_to :bill, class_name: "SharedBills::Bill"
    belongs_to :payee, class_name: "SharedBills::Payee"

    validates :amount_cents, presence: true
    validates :paid, inclusion: {in: [true, false]}
    validates :payee_id,
      uniqueness: {scope: :bill_id}
  end
end
