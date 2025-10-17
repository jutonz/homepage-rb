FactoryBot.define do
  factory :shared_bill, class: "SharedBills::SharedBill" do
    user
    sequence(:name) { "Shared Bill #{it}" }
  end
end
