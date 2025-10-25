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
end
