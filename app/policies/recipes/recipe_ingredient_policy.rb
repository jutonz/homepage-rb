# typed: true

module Recipes
  class RecipeIngredientPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Recipes::RecipeIngredient} }

    def index?
      user_owns_record?
    end

    def new?
      user_owns_record?
    end

    def create?
      user_owns_record?
    end

    private

    def user_owns_record?
      user && record.recipe&.user == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none if user.blank?
        scope.joins(:recipe).where(recipe: {user:})
      end
    end
  end
end
