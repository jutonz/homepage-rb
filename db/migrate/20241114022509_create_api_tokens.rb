class CreateApiTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :api_tokens do |t|
      t.string(:name, null: false)
      t.string(:token, null: false, index: {unique: true})
      t.references(:user, null: false)
      t.timestamps
    end

    add_index(:api_tokens, [:user_id, :name], unique: true)
  end
end
