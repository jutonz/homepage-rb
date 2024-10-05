FactoryBot.define do
  factory :todo_task, class: "Todo::Task" do
    user
    sequence(:name) { "Task #{_1}" }
    sequence(:todoist_id) { "todoist_id_#{_1}" }
  end
end
