class CreateTodoTaskOccurrences < ActiveRecord::Migration[8.0]
  def change
    create_table :todo_task_occurrences do |t|
      t.references :todo_task, null: false, foreign_key: true
      t.string :todoist_task_id, null: false
      t.datetime :scheduled_at, null: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :todo_task_occurrences, :todoist_task_id, unique: true
  end
end
