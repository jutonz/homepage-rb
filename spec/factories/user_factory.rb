# == Schema Information
#
# Table name: users
# Database name: primary
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
    sequence(:email) { "user#{it}@example.com" }
    sequence(:foreign_id) { it.to_s }
    access_token { "fake_token_#{foreign_id}" }
    refresh_token { "refresh_token" }

    trait :with_valid_token do
      access_token { build(:access_token, user: instance) }
    end
  end
end
