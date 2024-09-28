class AddUserToTodoRooms < ActiveRecord::Migration[7.2]
  def change
    add_reference(:todo_rooms, :user, null: false)
  end
end
