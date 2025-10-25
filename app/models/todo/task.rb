# == Schema Information
#
# Table name: todo_tasks
# Database name: primary
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
    has_many :task_occurrences, foreign_key: :todo_task_id, dependent: :destroy

    validates :name, presence: true

    def available_for_scheduling?
      !has_active_occurrence?
    end

    def has_active_occurrence?
      task_occurrences.scheduled.exists?
    end

    def current_occurrence
      task_occurrences.scheduled.first
    end

    def last_completed_occurrence
      task_occurrences.completed.order(completed_at: :desc).first
    end

    def status
      if has_active_occurrence?
        "scheduled"
      else
        "available"
      end
    end
  end
end
