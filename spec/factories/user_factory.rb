FactoryBot.define do
  factory(:user) do
    sequence(:email) { "user#{_1}@exmaple.com" }
    sequence(:foreign_id) { _1.to_s }
    access_token { build(:access_token, user: instance) }
    refresh_token { "refresh_token" }
  end
end
