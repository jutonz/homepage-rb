# == Schema Information
#
# Table name: api_tokens
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
module Api
  class Token < ApplicationRecord
    self.table_name = "api_tokens"

    belongs_to :user

    validates :name, presence: true, uniqueness: true
    validates :token, presence: true, uniqueness: {scope: :user_id}

    before_validation :generate_token

    def generate_token
      self.token ||= SecureRandom.hex(32)
    end
  end
end
