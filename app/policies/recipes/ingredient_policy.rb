# typed: true

module Recipes
  class IngredientPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Recipes::Ingredient} }
  end
end
