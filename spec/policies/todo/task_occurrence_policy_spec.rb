require "rails_helper"

RSpec.describe Todo::TaskOccurrencePolicy do
  permissions :create?, :update?, :destroy? do
    it "grants access when user owns the todo task" do
      user = build(:user)
      task = build(:todo_task, user:)
      task_occurrence = build(:todo_task_occurrence, todo_task: task)

      expect(described_class).to permit(user, task_occurrence)
    end

    it "denies access when user does not own the todo task" do
      user = build(:user)
      other_user = build(:user)
      task = build(:todo_task, user: other_user)
      task_occurrence = build(:todo_task_occurrence, todo_task: task)

      expect(described_class).not_to permit(user, task_occurrence)
    end

    it "denies access when user is nil" do
      task = build(:todo_task)
      task_occurrence = build(:todo_task_occurrence, todo_task: task)

      expect(described_class).not_to permit(nil, task_occurrence)
    end
  end

  describe described_class::Scope do
    it "returns only task occurrences from tasks belonging to the user" do
      user = create(:user)
      other_user = create(:user)
      user_task = create(:todo_task, user:)
      other_task = create(:todo_task, user: other_user)
      user_occurrence = create(:todo_task_occurrence, todo_task: user_task)
      create(:todo_task_occurrence, todo_task: other_task)

      scope = described_class.new(user, Todo::TaskOccurrence.all).resolve

      expect(scope).to contain_exactly(user_occurrence)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      task = create(:todo_task, user:)
      create(:todo_task_occurrence, todo_task: task)

      scope = described_class.new(nil, Todo::TaskOccurrence.all).resolve

      expect(scope).to be_empty
    end
  end
end
