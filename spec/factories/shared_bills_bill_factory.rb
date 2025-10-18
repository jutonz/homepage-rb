FactoryBot.define do
  factory :shared_bills_bill, class: "SharedBills::Bill" do
    association :shared_bill, factory: :shared_bill
    period_start { 1.month.ago.beginning_of_month }
    period_end { 1.month.ago.end_of_month }
  end
end
