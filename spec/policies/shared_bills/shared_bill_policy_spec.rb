require "rails_helper"

RSpec.describe SharedBills::SharedBillPolicy do
  it "inherits from UserOwnedPolicy" do
    expect(described_class.ancestors).to include(UserOwnedPolicy)
  end
end
