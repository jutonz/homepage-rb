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
require "rails_helper"

RSpec.describe Todo::RoomTask do
  it { is_expected.to belong_to(:room) }
  it { is_expected.to belong_to(:task) }
end
