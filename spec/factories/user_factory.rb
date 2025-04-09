# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  access_token  :string           not null
#  email         :string           not null
#  refresh_token :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  foreign_id    :string           not null
#
# Indexes
#
#  index_users_on_email       (email) UNIQUE
#  index_users_on_foreign_id  (foreign_id) UNIQUE
#
FactoryBot.define do
  factory(:user) do
    sequence(:email) { "user#{it}@exmaple.com" }
    sequence(:foreign_id) { it.to_s }
    access_token { build(:access_token, user: instance) }
    refresh_token { "refresh_token" }
  end
end
