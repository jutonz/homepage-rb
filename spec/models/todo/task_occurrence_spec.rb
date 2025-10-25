# == Schema Information
#
# Table name: todo_task_occurrences
# Database name: primary
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
require "rails_helper"

RSpec.describe Todo::TaskOccurrence, type: :model do
  subject { build(:todo_task_occurrence) }

  it { is_expected.to belong_to(:todo_task) }

  it { is_expected.to validate_presence_of(:todoist_task_id) }
  it { is_expected.to validate_presence_of(:scheduled_at) }
  it { is_expected.to validate_uniqueness_of(:todoist_task_id) }

  describe "#scheduled?" do
    it "returns true when completed_at is nil" do
      task_occurrence = build(:todo_task_occurrence, completed_at: nil)

      expect(task_occurrence.scheduled?).to be true
    end

    it "returns false when completed_at is present" do
      task_occurrence = build(:todo_task_occurrence, :completed)

      expect(task_occurrence.scheduled?).to be false
    end
  end

  describe "#completed?" do
    it "returns true when completed_at is present" do
      task_occurrence = build(:todo_task_occurrence, :completed)

      expect(task_occurrence.completed?).to be true
    end

    it "returns false when completed_at is nil" do
      task_occurrence = build(:todo_task_occurrence, completed_at: nil)

      expect(task_occurrence.completed?).to be false
    end
  end

  describe "#complete!" do
    it "sets completed_at" do
      task_occurrence = create(:todo_task_occurrence)

      freeze_time do
        completion_time = Time.current
        task_occurrence.complete!

        expect(task_occurrence.completed_at.to_i).to eq(completion_time.to_i)
        expect(task_occurrence.completed?).to be true
      end
    end
  end

  describe "#duration" do
    it "returns the duration between scheduled_at and completed_at" do
      freeze_time do
        scheduled_time = 1.hour.ago
        completed_time = Time.current
        task_occurrence = create(:todo_task_occurrence,
          scheduled_at: scheduled_time,
          completed_at: completed_time)

        expect(task_occurrence.duration).to be_within(1.second).of(1.hour)
      end
    end

    it "returns nil if not completed" do
      task_occurrence = create(:todo_task_occurrence)

      expect(task_occurrence.duration).to be_nil
    end
  end
end
