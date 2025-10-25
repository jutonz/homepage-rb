# == Schema Information
#
# Table name: api_tokens
# Database name: primary
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_api_tokens_on_token             (token) UNIQUE
#  index_api_tokens_on_user_id           (user_id)
#  index_api_tokens_on_user_id_and_name  (user_id,name) UNIQUE
#
FactoryBot.define do
  factory :api_token, class: "Api::Token" do
    user
    sequence(:name) { "Api Token #{it}" }
    sequence(:token) { "token#{it}" }
  end
end
