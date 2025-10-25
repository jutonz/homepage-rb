# == Schema Information
#
# Table name: user_groups
# Database name: primary
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  users_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint           not null
#
# Indexes
#
#  index_user_groups_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
FactoryBot.define do
  factory(:user_group) do
    sequence(:name) { "Group #{it}" }
    owner(factory: :user)

    after(:build) do |user_group, evaluator|
      user_group.users << evaluator.owner
    end
  end
end
