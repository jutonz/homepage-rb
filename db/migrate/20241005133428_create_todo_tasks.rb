class CreateTodoTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :todo_tasks do |t|
      t.string(:name, null: false)
      t.string(:todoist_id, null: false)
      t.timestamps
    end

    create_table :todo_room_tasks do |t|
      t.references(
        :task,
        null: false,
        foreign_key: {to_table: :todo_tasks}
      )
      t.references(
        :room,
        null: false,
        foreign_key: {to_table: :todo_rooms}
      )
      t.timestamps
    end
  end
end
