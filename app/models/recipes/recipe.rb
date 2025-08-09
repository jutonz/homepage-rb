# == Schema Information
#
# Table name: recipes_recipes
#
#  id           :bigint           not null, primary key
#  description  :text
#  instructions :text
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_recipes_recipes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module Recipes
  class Recipe < ApplicationRecord
    belongs_to :user
    has_many :recipe_ingredients,
      class_name: "Recipes::RecipeIngredient",
      dependent: :destroy
    has_many :ingredients,
      through: :recipe_ingredients,
      class_name: "Recipes::Ingredient"

    validates :name, presence: true
  end
end
