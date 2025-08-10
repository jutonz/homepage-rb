# == Schema Information
#
# Table name: recipes_recipe_ingredients
#
#  id            :bigint           not null, primary key
#  denominator   :integer
#  notes         :text
#  numerator     :integer
#  quantity      :decimal(8, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null
#  recipe_id     :bigint           not null
#  unit_id       :bigint           not null
#
# Indexes
#
#  idx_on_recipe_id_ingredient_id_b1a1ea5019          (recipe_id,ingredient_id) UNIQUE
#  index_recipes_recipe_ingredients_on_ingredient_id  (ingredient_id)
#  index_recipes_recipe_ingredients_on_recipe_id      (recipe_id)
#  index_recipes_recipe_ingredients_on_unit_id        (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => recipes_ingredients.id)
#  fk_rails_...  (recipe_id => recipes_recipes.id)
#  fk_rails_...  (unit_id => recipes_units.id)
#
require Rails.root.join("lib", "fraction_parser")
require Rails.root.join("lib", "fraction_formatter")

module Recipes
  class RecipeIngredient < ApplicationRecord
    belongs_to :recipe, class_name: "Recipes::Recipe"
    belongs_to :ingredient, class_name: "Recipes::Ingredient"
    belongs_to :unit, class_name: "Recipes::Unit"

    validates :recipe_id,
      presence: true,
      uniqueness: {scope: :ingredient_id}
    validates :ingredient_id, presence: true
    validates :quantity,
      presence: true,
      numericality: {greater_than: 0}

    validate :fraction_is_valid

    def quantity_string=(value)
      num, denom = FractionParser.parse(value)

      if num && denom
        self.numerator = num
        self.denominator = denom
        self.quantity = num.to_f / denom
      else
        # Clear fraction fields if invalid
        self.numerator = nil
        self.denominator = nil
        # Try to parse as decimal for backward compatibility
        if value.present? && value.to_f > 0
          self.quantity = value.to_f
        end
      end
    end

    def quantity_string
      if numerator.present? && denominator.present?
        FractionFormatter.format(numerator, denominator)
      elsif quantity.present?
        quantity.to_s
      else
        ""
      end
    end

    def formatted_quantity(use_unicode: false)
      if numerator.present? && denominator.present?
        FractionFormatter.format(numerator, denominator, use_unicode:)
      elsif quantity.present?
        quantity.to_s
      else
        ""
      end
    end

    private

    def fraction_is_valid
      if numerator.present? && denominator.blank?
        errors.add(:denominator, "must be present when numerator is set")
      elsif numerator.blank? && denominator.present?
        errors.add(:numerator, "must be present when denominator is set")
      elsif denominator.present? && denominator == 0
        errors.add(:denominator, "cannot be zero")
      elsif numerator.present? && numerator <= 0
        errors.add(:numerator, "must be greater than zero")
      end
    end
  end
end
