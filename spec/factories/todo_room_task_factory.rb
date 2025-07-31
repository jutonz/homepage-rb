FactoryBot.define do
  factory :todo_room_task, class: "Todo::RoomTask" do
    association :room, factory: :todo_room
    association :task, factory: :todo_task
  end
end
