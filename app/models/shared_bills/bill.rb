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
module SharedBills
  class Bill < ActiveRecord::Base
    belongs_to :shared_bill,
      class_name: "SharedBills::SharedBill"
    has_many :payee_bills,
      class_name: "SharedBills::PayeeBill",
      foreign_key: :bill_id,
      dependent: :destroy
    has_many :payees,
      through: :payee_bills,
      class_name: "SharedBills::Payee"

    validates :name, presence: true
  end
end
