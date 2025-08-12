class DeleteExistingUserGroupsAndMemberships < ActiveRecord::Migration[8.0]
  def up
    UserGroupMembership.delete_all
    UserGroup.delete_all
  end

  def down
    # No need to restore data - this is a clean slate approach
  end
end
