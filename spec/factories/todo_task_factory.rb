FactoryBot.define do
  factory :todo_task, class: "Todo::Task" do
    user
    sequence(:name) { "Task #{it}" }

    trait :with_room do
      rooms { [build(:todo_room, tasks: [instance], user: instance.user)] }
    end
  end
end
