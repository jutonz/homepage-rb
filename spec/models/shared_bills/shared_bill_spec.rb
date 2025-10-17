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
require "rails_helper"

RSpec.describe SharedBills::SharedBill do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:bills) }
  it { is_expected.to have_many(:payees) }
  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:shared_bill)).to be_valid
  end
end
