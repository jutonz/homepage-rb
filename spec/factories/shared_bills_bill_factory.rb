FactoryBot.define do
  factory :shared_bills_bill, class: "SharedBills::Bill" do
    association :shared_bill, factory: :shared_bill
    sequence(:name) { "Bill #{it}" }
  end
end
