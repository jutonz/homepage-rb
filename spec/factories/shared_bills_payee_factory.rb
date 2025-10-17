FactoryBot.define do
  factory :shared_bills_payee,
    class: "SharedBills::Payee" do
    association :shared_bill, factory: :shared_bill
    sequence(:name) { "Payee #{it}" }
  end
end
