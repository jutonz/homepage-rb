# == Schema Information
#
# Table name: todo_rooms
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Todo
  class Room < ActiveRecord::Base
    self.table_name = "todo_rooms"

    validates :name, presence: true
  end
end
