# == Schema Information
#
# Table name: todo_rooms
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
#  index_todo_rooms_on_user_id  (user_id)
#
require "rails_helper"

RSpec.describe Todo::Room do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:room_tasks) }
  it { is_expected.to have_many(:tasks) }

  it { is_expected.to validate_presence_of(:name) }
end
