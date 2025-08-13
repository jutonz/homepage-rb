class CreateUserGroupInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_group_invitations do |t|
      t.string :email, null: false
      t.references :user_group, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.references :invited_by, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end

    add_index :user_group_invitations, :token, unique: true
    add_index :user_group_invitations, :email
    add_index :user_group_invitations, [:email, :user_group_id], unique: true
    add_index :user_group_invitations, :expires_at
    add_index :user_group_invitations, :accepted_at
  end
end
