FactoryBot.define do
  factory :todo_task, class: "Todo::Task" do
    user
    sequence(:name) { "Task #{_1}" }
  end
end
