# == Schema Information
#
# Table name: recipes_units
# Database name: primary
#
#  id           :bigint           not null, primary key
#  abbreviation :string           not null
#  name         :string           not null
#  unit_type    :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_recipes_units_on_abbreviation  (abbreviation) UNIQUE
#  index_recipes_units_on_name          (name) UNIQUE
#  index_recipes_units_on_unit_type     (unit_type)
#
module Recipes
  class Unit < ApplicationRecord
    has_many :recipe_ingredients,
      class_name: "Recipes::RecipeIngredient",
      dependent: :restrict_with_error

    validates :name, presence: true, uniqueness: true
    validates :abbreviation, presence: true, uniqueness: true
    validates :unit_type,
      presence: true,
      inclusion: {in: %w[volume weight count]}
  end
end
