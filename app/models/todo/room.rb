# == Schema Information
#
# Table name: todo_rooms
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_todo_rooms_on_user_id  (user_id)
#
module Todo
  class Room < ActiveRecord::Base
    self.table_name = "todo_rooms"

    belongs_to :user

    validates :name, presence: true
  end
end
