class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string(:email, null: false, index: {unique: true})
      t.string(:foreign_id, null: false, index: {unique: true})
      t.string(:access_token, null: false)
      t.string(:refresh_token, null: false)
      t.timestamps
    end
  end
end
