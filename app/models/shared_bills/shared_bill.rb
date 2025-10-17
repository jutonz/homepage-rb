# == Schema Information
#
# Table name: shared_bills_shared_bills
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_shared_bills_shared_bills_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module SharedBills
  class SharedBill < ActiveRecord::Base
    belongs_to :user
    has_many :bills,
      class_name: "SharedBills::Bill",
      foreign_key: :shared_bill_id,
      dependent: :destroy
    has_many :payees,
      class_name: "SharedBills::Payee",
      foreign_key: :shared_bill_id,
      dependent: :destroy

    validates :name, presence: true
  end
end
