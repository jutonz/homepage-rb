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
class User < ActiveRecord::Base
  has_one_attached :avatar
  has_many :api_tokens, class_name: "Api::Token"
  has_many :galleries
  has_many :owned_recipe_groups,
    class_name: "RecipeGroup",
    foreign_key: "owner_id"
  has_many :owned_user_groups, class_name: "UserGroup", foreign_key: "owner_id"
  has_many :plants, class_name: "Plants::Plant"
  has_many :recipes_ingredients, class_name: "Recipes::Ingredient"
  has_many :recipes_recipes, class_name: "Recipes::Recipe"
  has_many :sent_user_group_invitations,
    class_name: "UserGroupInvitation",
    foreign_key: "invited_by_id"
  has_many :shared_bills,
    class_name: "SharedBills::SharedBill"
  has_many :todo_rooms, class_name: "Todo::Room"
  has_many :todo_tasks, class_name: "Todo::Task"
  has_many :user_group_memberships
  has_many :user_groups, through: :user_group_memberships
end
