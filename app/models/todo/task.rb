# == Schema Information
#
# Table name: todo_tasks
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  todoist_id :string           not null
#
module Todo
  class Task < ActiveRecord::Base
    self.table_name = "todo_tasks"

    has_many :room_tasks
    has_many :rooms, through: :room_tasks
  end
end
