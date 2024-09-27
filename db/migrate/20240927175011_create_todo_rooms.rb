class CreateTodoRooms < ActiveRecord::Migration[7.2]
  def change
    create_table :todo_rooms do |t|
      t.string(:name, null: false)
      t.timestamps
    end
  end
end
