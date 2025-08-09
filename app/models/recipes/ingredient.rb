# == Schema Information
#
# Table name: recipes_ingredients
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_recipes_ingredients_on_user_id           (user_id)
#  index_recipes_ingredients_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module Recipes
  class Ingredient < ApplicationRecord
    belongs_to :user
    has_many :recipe_ingredients,
      class_name: "Recipes::RecipeIngredient",
      dependent: :destroy
    has_many :recipes,
      through: :recipe_ingredients,
      class_name: "Recipes::Recipe"

    validates :name, presence: true, uniqueness: {scope: :user_id}
  end
end
