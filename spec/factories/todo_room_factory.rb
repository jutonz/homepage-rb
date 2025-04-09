FactoryBot.define do
  factory(:todo_room, class: "Todo::Room") do
    sequence(:name) { "Room#{it}" }
    user

    trait :with_task do
      tasks { [build(:todo_task, rooms: [instance], user: instance.user)] }
    end
  end
end
