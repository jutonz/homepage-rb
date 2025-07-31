# == Schema Information
#
# Table name: todo_task_occurrences
#
#  id              :bigint           not null, primary key
#  completed_at    :datetime
#  scheduled_at    :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  todo_task_id    :bigint           not null
#  todoist_task_id :string           not null
#
# Indexes
#
#  index_todo_task_occurrences_on_todo_task_id     (todo_task_id)
#  index_todo_task_occurrences_on_todoist_task_id  (todoist_task_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (todo_task_id => todo_tasks.id)
#
module Todo
  class TaskOccurrence < ApplicationRecord
    self.table_name = "todo_task_occurrences"

    belongs_to :todo_task, class_name: "Todo::Task"

    validates :todoist_task_id, presence: true, uniqueness: true
    validates :scheduled_at, presence: true

    scope :scheduled, -> { where(completed_at: nil) }
    scope :completed, -> { where.not(completed_at: nil) }

    def scheduled?
      completed_at.nil?
    end

    def completed?
      completed_at.present?
    end

    def complete!
      update!(completed_at: Time.current)
    end

    def duration
      return unless completed_at && scheduled_at
      completed_at - scheduled_at
    end
  end
end
