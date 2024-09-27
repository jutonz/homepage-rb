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
class User < ActiveRecord::Base
end
