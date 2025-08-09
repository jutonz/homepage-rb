# == Schema Information
#
# Table name: ingredients
#
#  id         :bigint           not null, primary key
#  category   :string
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ingredients_on_user_id           (user_id)
#  index_ingredients_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Ingredient < ApplicationRecord
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  validates :name, presence: true, uniqueness: {scope: :user_id}
  validates :user_id, presence: true
end
