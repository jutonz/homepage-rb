# == Schema Information
#
# Table name: todo_room_tasks
# Database name: primary
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  room_id    :bigint           not null
#  task_id    :bigint           not null
#
# Indexes
#
#  index_todo_room_tasks_on_room_id  (room_id)
#  index_todo_room_tasks_on_task_id  (task_id)
#
# Foreign Keys
#
#  fk_rails_...  (room_id => todo_rooms.id)
#  fk_rails_...  (task_id => todo_tasks.id)
#
module Todo
  class RoomTask < ActiveRecord::Base
    self.table_name = "todo_room_tasks"

    belongs_to :room, class_name: "Todo::Room"
    belongs_to :task, class_name: "Todo::Task"
  end
end
