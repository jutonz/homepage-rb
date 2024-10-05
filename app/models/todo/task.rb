# == Schema Information
#
# Table name: todo_tasks
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_todo_tasks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module Todo
  class Task < ActiveRecord::Base
    self.table_name = "todo_tasks"

    belongs_to :user
    has_many :room_tasks
    has_many :rooms, through: :room_tasks
  end
end
