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
require "rails_helper"

RSpec.describe Todo::Task do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:room_tasks) }
  it { is_expected.to have_many(:rooms) }

  it "has a valid factory" do
    expect(build(:todo_task)).to be_valid
  end

  describe "scheduling" do
    it "is available when it has no scheduled occurrence" do
      task = create(:todo_task)

      expect(task).to be_available_for_scheduling
      expect(task).not_to have_active_occurrence
      expect(task.current_occurrence).to be_nil
      expect(task.status).to eq("available")
    end

    it "returns its scheduled and latest completed occurrences" do
      task = create(:todo_task)
      earlier = create(:todo_task_occurrence, :completed, todo_task: task,
        completed_at: 2.hours.ago)
      later = create(:todo_task_occurrence, :completed, todo_task: task,
        completed_at: 1.hour.ago)
      scheduled = create(:todo_task_occurrence, todo_task: task)

      expect(task).not_to be_available_for_scheduling
      expect(task).to have_active_occurrence
      expect(task.current_occurrence).to eq(scheduled)
      expect(task.last_completed_occurrence).to eq(later)
      expect(task.last_completed_occurrence).not_to eq(earlier)
      expect(task.status).to eq("scheduled")
    end
  end
end
