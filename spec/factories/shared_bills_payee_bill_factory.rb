FactoryBot.define do
  factory :shared_bills_payee_bill,
    class: "SharedBills::PayeeBill" do
    association :bill, factory: :shared_bills_bill
    association :payee, factory: :shared_bills_payee
    sequence(:amount_cents) { (it * 100) + 1000 }
    paid

    trait(:paid) { paid { true } }
    trait(:unpaid) { paid { false } }
  end
end
