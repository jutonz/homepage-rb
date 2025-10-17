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
end
