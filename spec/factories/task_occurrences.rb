# == Schema Information
#
# Table name: task_occurrences
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
#  index_task_occurrences_on_todo_task_id     (todo_task_id)
#  index_task_occurrences_on_todoist_task_id  (todoist_task_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (todo_task_id => todo_tasks.id)
#
FactoryBot.define do
  factory :todo_task_occurrence, class: "Todo::TaskOccurrence" do
    association :todo_task, factory: :todo_task
    todoist_task_id { SecureRandom.uuid }
    scheduled_at { Time.current }

    trait :completed do
      completed_at { Time.current }
    end
  end
end
