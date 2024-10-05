# == Schema Information
#
# Table name: todo_tasks
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  todoist_id :string           not null
#
require "rails_helper"

RSpec.describe Todo::Task do
  it { is_expected.to have_many(:room_tasks) }
  it { is_expected.to have_many(:rooms) }

  it "has a valid factory" do
    expect(build(:todo_task)).to be_valid
  end
end
