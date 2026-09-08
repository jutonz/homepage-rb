# typed: true

module Recipes
  class RecipePolicy < UserOwnedPolicy
    Record = type_member { {fixed: Recipes::Recipe} }
  end
end
