# == Schema Information
#
# Table name: user_group_memberships
# Database name: primary
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_group_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_user_group_memberships_on_user_group_id              (user_group_id)
#  index_user_group_memberships_on_user_id                    (user_id)
#  index_user_group_memberships_on_user_id_and_user_group_id  (user_id,user_group_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_group_id => user_groups.id)
#  fk_rails_...  (user_id => users.id)
#
class UserGroupMembership < ActiveRecord::Base
  belongs_to(:user)
  belongs_to(:user_group, counter_cache: :users_count)

  validates(:user_id, uniqueness: {scope: :user_group_id})
end
