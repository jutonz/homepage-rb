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
class UserGroup < ActiveRecord::Base
  belongs_to(:owner, class_name: "User")
  has_many(:user_group_memberships, dependent: :destroy)
  has_many(:users, through: :user_group_memberships)
  has_many(:user_group_invitations, dependent: :destroy)

  validates(:name, presence: true)
end
