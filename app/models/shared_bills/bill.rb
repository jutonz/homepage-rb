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

    def self.with_payee_info
      select(
        "#{table_name}.*",
        "(SELECT COALESCE(SUM(amount_cents), 0)
          FROM shared_bills_payee_bills
          WHERE bill_id = #{table_name}.id) AS total_amount",
        "(SELECT COALESCE(BOOL_AND(paid), false)
          FROM shared_bills_payee_bills
          WHERE bill_id = #{table_name}.id) AS all_payees_paid"
      )
    end
  end
end
