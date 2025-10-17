FactoryBot.define do
  factory :shared_bills_payee_bill,
    class: "SharedBills::PayeeBill" do
    association :bill, factory: :shared_bills_bill
    association :payee, factory: :shared_bills_payee
    sequence(:amount) { (it * 100) + 1000 }
    paid { false }
  end
end
