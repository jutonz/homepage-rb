FactoryBot.define do
  factory(:todo_room, class: "Todo::Room") do
    sequence(:name) { "Room#{_1}" }
    user
  end
end
