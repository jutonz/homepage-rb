require "rails_helper"

RSpec.describe Todo::Task do
  it { is_expected.to have_many(:room_tasks) }
  it { is_expected.to have_many(:rooms) }

  it "has a valid factory" do
    expect(build(:todo_task)).to be_valid
  end
end
