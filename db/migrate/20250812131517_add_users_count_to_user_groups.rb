class AddUsersCountToUserGroups < ActiveRecord::Migration[8.0]
  def change
    add_column(:user_groups, :users_count, :integer, null: false, default: 0)

    reversible do |dir|
      dir.up do
        UserGroup.find_each do |user_group|
          UserGroup.reset_counters(user_group.id, :users)
        end
      end
    end
  end
end
