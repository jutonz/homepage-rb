class RemoveTodoistIdFromTodoTasks < ActiveRecord::Migration[7.2]
  def change
    remove_column(
      :todo_tasks,
      :todoist_id,
      :string,
      null: false
    )
  end
end
