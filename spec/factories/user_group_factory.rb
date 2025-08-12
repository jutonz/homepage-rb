# == Schema Information
#
# Table name: user_groups
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

    transient do
      owner { create(:user) }
    end

    initialize_with do
      creator = UserGroupCreator.call(owner:, name:)
      creator.user_group
    end
  end
end
